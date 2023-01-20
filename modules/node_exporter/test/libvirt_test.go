package tests

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func Test(t *testing.T) {
	terraformDir := test_structure.CopyTerraformFolderToTemp(t, "../../../", "modules/node_exporter/test/fixtures")
	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		Logger:       logger.New(logger.Discard),
		Vars:         map[string]interface{}{},
	}

	// Apply terraform
	terraform.InitAndApplyAndIdempotent(t, terraformOptions)
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
	description := fmt.Sprintf("SSH to public host %s", instanceIP)
	retry.DoWithRetry(t, description, 30, 5*time.Second, func() (string, error) {
		return ssh.CheckSshCommandE(t, host, "true")
	})

	t.Run("test_service_status", func(t *testing.T) {
		expectedText := "active"
		command := "systemctl is-active podman-kube@-usr-local-etc-kube-node_exporter.yml.service"
		_, err := retry.DoWithRetryE(t, description, 5, 5*time.Second, func() (string, error) {
			actualText, _ := ssh.CheckSshCommandE(t, host, command)
			if strings.TrimSpace(actualText) != expectedText {
				return actualText, fmt.Errorf("Not yet \"%s\" but instead \"%s\".", expectedText, actualText)
			}
			return actualText, nil
		})
		assert.Nil(t, err, "The service should become active (running).")
	})
}
