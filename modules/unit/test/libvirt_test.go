package tests

import (
	"errors"
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

// Test Unit Module
func TestUnit(t *testing.T) {
	terraformDir := test_structure.CopyTerraformFolderToTemp(t, "../../../", "modules/unit/test/fixtures")
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

	t.Run(fmt.Sprintf("test_service_status_%s_%s", "core", "unit_0.service"), func(t *testing.T) {
		var command string
		expectedText := "active"
		command = "systemctl --user is-active unit_0.service"
		actualText, _ := retry.DoWithRetryE(t, "Test service status", 100, 2*time.Second, func() (string, error) {
			actualText := strings.TrimSpace(func() string {
				response, _ := ssh.CheckSshCommandE(t, host, command)
				return response
			}())
			if actualText == expectedText {
				return actualText, nil
			}
			return actualText, errors.New("the unit is not in active state")
		})
		assert.Equal(t, expectedText, actualText,
			fmt.Sprintf("The systemctl status return should equal %s in time.", expectedText))
	})
}
