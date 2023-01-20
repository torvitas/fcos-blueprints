package tests

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func Test(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "fixtures",
		Vars:         map[string]interface{}{},
	}

	// Apply terraform
	// terraform.InitAndApplyAndIdempotent(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)

	instanceIP := terraform.Output(t, terraformOptions, "ip_address")
	sshKeyPair := &ssh.KeyPair{
		PrivateKey: terraform.Output(t, terraformOptions, "private_key_openssh"),
		PublicKey:  "",
	}
	host := ssh.Host{
		Hostname:    instanceIP,
		SshKeyPair:  sshKeyPair,
		SshUserName: "core",
	}

	// Verify that we can SSH to the instance and run commands
	// It can take about a minute for the instance to boot up, so retry a few times
	maxRetries := 30
	timeBetweenRetries := 5 * time.Second
	description := fmt.Sprintf("SSH to public host %s", instanceIP)
	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		return ssh.CheckSshCommandE(t, host, "true")
	})

	// Verify all pod services have drop-ins that wait for the corresponding mounts
	for _, pod := range []struct {
		name, user string
	}{
		{
			user: "root",
			name: "busybox_0",
		},
		{
			user: "root",
			name: "busybox_1",
		},
		{
			user: "core",
			name: "busybox_0",
		},
		{
			user: "core",
			name: "busybox_1",
		},
	} {
		var expectedText, command string
		if pod.user == "root" {
			expectedText = "RequiresMountsFor=/var/lib/containers/storage/volumes"
			command = fmt.Sprintf("systemctl cat podman-kube@-usr-local-etc-kube-%s.yml.service", pod.name)
		} else {
			expectedText = fmt.Sprintf("RequiresMountsFor=/var/home/%s/.local/share/containers/storage/volumes", pod.user)
			command = fmt.Sprintf(
				"systemctl --user cat podman-kube@-var-home-%s-.local-etc-kube-%s.yml.service",
				pod.user,
				pod.name,
			)
		}
		t.Run(fmt.Sprintf("test_dropins_%s_%s", pod.user, pod.name), func(t *testing.T) {
			actualText, _ := ssh.CheckSshCommandE(t, host, command)

			assert.Contains(t, actualText, expectedText,
				fmt.Sprintf("The systemctl cat return should contain %s", expectedText))
		})
	}

	t.Run("test_container_persistence", func(t *testing.T) {

		// Run pod and echo text to file in volume
		expectedText := "I can has persistence plx"
		command := fmt.Sprintf(
			"podman run --rm -v persistence-test:/opt docker.nexus.breuni.io/library/alpine:3.16 /bin/sh -c \"echo %s > /opt/my_test_file\"",
			expectedText,
		)
		_, err := ssh.CheckSshCommandE(t, host, command)
		assert.Nil(t, err, "The echo should not error.")

		// Make sure the filesystems are actually fully persisted before destroy
		ssh.CheckSshCommandE(t, host, "sync")

		// Taint virtual machine and root disk before running apply to recreate virtual machine
		terraform.RunTerraformCommand(
			t,
			terraformOptions,
			"taint",
			"module.libvirt_test_vm.libvirt_domain.this",
		)
		terraform.RunTerraformCommand(
			t,
			terraformOptions,
			"taint",
			"module.libvirt_test_vm.libvirt_volume.root",
		)
		terraform.Apply(t, terraformOptions)

		// Update ssh arguments and wait for machine to come up again
		instanceIP := terraform.Output(t, terraformOptions, "ip_address")
		host.Hostname = instanceIP
		retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
			return ssh.CheckSshCommandE(t, host, "true")
		})

		// Assert persistence by getting text from file in volume
		command = "podman run --rm -v persistence-test:/opt docker.nexus.breuni.io/library/alpine:3.16 cat /opt/my_test_file"
		actualText, _ := ssh.CheckSshCommandE(t, host, command)
		assert.Contains(t, actualText, expectedText,
			fmt.Sprintf("The command return should contain %s.", expectedText))
	})
}
