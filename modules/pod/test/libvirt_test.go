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
	// defer terraform.Destroy(t, terraformOptions)

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

	// It can take a minute or so for the Instance to boot up, so retry a few times
	maxRetries := 30
	timeBetweenRetries := 5 * time.Second
	description := fmt.Sprintf("SSH to public host %s", instanceIP)

	// Verify that we can SSH to the Instance and run commands
	retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
		return ssh.CheckSshCommandE(t, host, "true")
	})

	t.Run("test_df_result_var_lib_containers", func(t *testing.T) {
		expectedText := "/var/lib/containers"
		command := "df /dev/disk/by-diskseq/2"
		actualText, _ := ssh.CheckSshCommandE(t, host, command)
		assert.Contains(t, actualText, expectedText,
			"The df return should contain /var/lib/containers.")
	})

	t.Run("test_df_result_var_home", func(t *testing.T) {
		expectedText := "/var/home"
		command := "df /dev/disk/by-diskseq/3"
		actualText, _ := ssh.CheckSshCommandE(t, host, command)
		assert.Contains(t, actualText, expectedText,
			"The df return should contain /var/home.")
	})

	for _, pod := range []struct {
		name, user string
	}{
		{
			user: "root",
			name: "nginx_0",
		},
		{
			user: "root",
			name: "nginx_1",
		},
		{
			user: "core",
			name: "nginx_0",
		},
		{
			user: "core",
			name: "nginx_1",
		},
	} {
		var expectedText, command string
		if pod.user == "root" {
			expectedText = "RequiresMountsFor=/var/lib/containers"
			command = fmt.Sprintf("systemctl cat podman-kube@-usr-local-etc-kube-%s.yml.service", pod.name)
		} else {
			expectedText = fmt.Sprintf("RequiresMountsFor=/var/home/%s/.local/share/containers", pod.user)
			command = fmt.Sprintf("systemctl --user cat podman-kube@-var-home-%s-.local-etc-kube-%s.yml.service", pod.user, pod.name)
		}
		t.Run(fmt.Sprintf("test_dropins_%s_%s", pod.user, pod.name), func(t *testing.T) {
			actualText, _ := ssh.CheckSshCommandE(t, host, command)

			assert.Contains(t, actualText, expectedText,
				fmt.Sprintf("The systemctl cat return should contain %s", expectedText))
		})
	}

	//	t.Run(fmt.Sprintf("test_dropin_%s", pod.name), func(t *testing.T) {
	//		expectedText := "RequiresMountsFor=/var/home/core/.local/share/containers"
	//		command := "systemctl --user cat podman-kube@-var-home-core-.local-etc-kube-nginx_0.yml.service"
	//		actualText, _ := ssh.CheckSshCommandE(t, host, command)
	//
	//		assert.Contains(t, actualText, expectedText,
	//			"The systemctl cat return should contain RequiresMountsFor=/var/home/core/.local/share/containers")
	//	})
	//
	// t.Run("test_container_persistence", func(t *testing.T) {
	// expectedText := "I can has persistence plx"
	// command := fmt.Sprintf("podman run --rm -v foo:/opt alpine:3.16 sh -c \"echo %s > /opt/my_test_file\"", expectedText)
	// ssh.CheckSshCommandE(t, host, command)
	// terraform.RunTerraformCommand(
	// t,
	// terraformOptions,
	// "taint",
	// "module.libvirt_test_vm.libvirt_domain.this",
	// )
	// terraform.RunTerraformCommand(
	// t,
	// terraformOptions,
	// "taint",
	// "module.libvirt_test_vm.libvirt_volume.root",
	// )
	// terraform.Apply(t, terraformOptions)
	// instanceIP := terraform.Output(t, terraformOptions, "ip_address")
	// host.Hostname = instanceIP
	// retry.DoWithRetry(t, description, maxRetries, timeBetweenRetries, func() (string, error) {
	// return ssh.CheckSshCommandE(t, host, "true")
	// })
	// command = "podman run --rm -v foo:/opt alpine:3.16 cat /opt/my_test_file"
	// actualText, _ := ssh.CheckSshCommandE(t, host, command)
	//
	// assert.Contains(t, actualText, expectedText,
	// fmt.Sprintf("The command return should contain %s.", expectedText))
	// })
}
