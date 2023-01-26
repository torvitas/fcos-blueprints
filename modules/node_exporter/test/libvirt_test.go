package tests

import (
	"errors"
	"fmt"
	"io/ioutil"
	"net/http"
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

func TestNodeExporter(t *testing.T) {
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
		actualText, _ := retry.DoWithRetryE(t, "Test service status", 5, 5*time.Second, func() (string, error) {
			actualText := strings.TrimSpace(func() string {
				response, _ := ssh.CheckSshCommandE(t, host, command)
				return response
			}())
			if actualText != expectedText {
				return actualText, errors.New("the pod service is not in active state")
			}
			return actualText, nil
		})
		assert.Equal(t, expectedText, actualText, "The service should become active (running).")
	})

	t.Run("test_service_reachability", func(t *testing.T) {
		expectedText := "node_memory"
		response, _ := http.Get(fmt.Sprintf("http://%s:9100/metrics", instanceIP))
		defer response.Body.Close()
		responseBody, _ := ioutil.ReadAll(response.Body)
		actualText := string(responseBody)
		assert.Contains(t, actualText, expectedText, fmt.Sprintf("The response should contain the metric %s", expectedText))
	})
}
