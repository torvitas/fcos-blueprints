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
	"github.com/stretchr/testify/require"
)

// Test Blueprints Module
func TestPod(t *testing.T) {
	terraformDir := test_structure.CopyTerraformFolderToTemp(t, "../", "test/fixtures")
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
	t.Run("test_ssh", func(t *testing.T) {
		description := fmt.Sprintf("SSH to public host %s", instanceIP)
		_, err := retry.DoWithRetryE(t, description, 30, 5*time.Second, func() (string, error) {
			return ssh.CheckSshCommandE(t, host, "true")
		})
		assert.Nil(t, err, "The ssh key should be authorized.")
	})

	// Pull rendered config to validate it's content
	output := terraform.Output(t, terraformOptions, "ignition")
	require.NotNil(t, output)

	t.Run("test_authorized_keys", func(t *testing.T) {
		assert.Contains(
			t,
			output,
			"\"sshAuthorizedKeys\": [",
			"There should be authorized keys in the output.",
		)
	})

	t.Run("test_ca", func(t *testing.T) {
		assert.Contains(
			t,
			output,
			"\"path\": \"/etc/pki/ca-trust/source/anchors/acse.pem\"",
			"The path to the CA should be defined in the output.",
		)
	})

	t.Run("test_directory_parents", func(t *testing.T) {
		assert.Contains(
			t,
			output,
			"\"path\": \"/var/home/core/i/can\"",
			"The path segment /var/home/core/i/can should be defined in the output.",
		)
		assert.Contains(
			t,
			output,
			"\"path\": \"/var/home/core/i/like\"",
			"The path segment /var/home/core/i/like should be defined in the output.",
		)
	})

	t.Run("test_node_exporter", func(t *testing.T) {
		assert.Contains(
			t,
			output,
			"\"path\": \"/usr/local/etc/kube/node_exporter.yml\"",
			"The path to the manifest should be defined in the output.",
		)
	})

	t.Run("test_node_exporter", func(t *testing.T) {
		assert.Contains(
			t,
			output,
			"\"path\": \"/usr/local/etc/kube/node_exporter.yml\"",
			"The path to the node exporter pod manifest should be defined in the output.",
		)
	})

	t.Run("test_pod", func(t *testing.T) {
		assert.Contains(
			t,
			output,
			"\"path\": \"/var/home/core/.local/etc/kube/nginx.yml\"",
			"The path to the nginx pod manifest should be defined in the output.",
		)
	})

	t.Run("test_unit", func(t *testing.T) {
		assert.Contains(
			t,
			output,
			"\"path\": \"/var/home/core/.config/systemd/user/default.target.wants/infinity\"",
			"The path to the infinity unit should be defined in the output.",
		)
	})
}
