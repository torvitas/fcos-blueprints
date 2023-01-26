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

func TestDirectoryParents(t *testing.T) {
	terraformDir := test_structure.CopyTerraformFolderToTemp(t, "../../../", "modules/directory_parents/test/fixtures")
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

	directoryParents := []string{
		"/var/home/core/a",
		"/var/home/core/a/company",
		"/var/home/core/a/company/that",
		"/var/home/core/a/company/that/makes",
		"/var/home/core/a/company/that/makes/folders",
	}
	for index, directory := range directoryParents {
		t.Run(fmt.Sprintf("test_owner_%d", index), func(t *testing.T) {
			actualText, _ := ssh.CheckSshCommandE(t, host, fmt.Sprintf("stat --format=\"%%U\" %s", directory))
			assert.Equal(t, "core", strings.TrimSpace(actualText), "The directory should belong to the core user.")
		})
		t.Run(fmt.Sprintf("test_group_%d", index), func(t *testing.T) {
			actualText, _ := ssh.CheckSshCommandE(t, host, fmt.Sprintf("stat --format=\"%%G\" %s", directory))
			assert.Equal(t, "core", strings.TrimSpace(actualText), "The directory should belong to the core group.")
		})
		t.Run(fmt.Sprintf("test_mode_%d", index), func(t *testing.T) {
			actualText, _ := ssh.CheckSshCommandE(t, host, fmt.Sprintf("stat --format=\"%%a\" %s", directory))
			assert.Equal(t, "755", strings.TrimSpace(actualText), "The directory permission should be 755.")
		})
	}
}
