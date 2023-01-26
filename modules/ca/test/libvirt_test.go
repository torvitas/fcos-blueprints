package tests

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/ssh"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestCa(t *testing.T) {
	terraformDir := test_structure.CopyTerraformFolderToTemp(t, "../../../", "modules/ca/test/fixtures")
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

	t.Run("test_curl_tls", func(t *testing.T) {
		_, err := retry.DoWithRetryE(t, "Test validity of https response.", 60, 2*time.Second, func() (string, error) {
			return ssh.CheckSshCommandE(t, host, "curl -f https://localhost:4443")
		})
		assert.Nil(t, err, "The nginx should yield a valid response.")
	})
}
