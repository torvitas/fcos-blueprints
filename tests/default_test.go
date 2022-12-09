package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestDefaultConfig(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars:         map[string]interface{}{},
	}

	// Apply terraform
	terraform.InitAndApply(t, terraformOptions)

	// Pull rendered config to validate it's content
	output := terraform.Output(t, terraformOptions, "rendered")
	assert.NotNil(t, output)
}

func TestAllFeaturesEnabledConfig(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"node_exporter_enabled": true,
			"open_vm_tools_enabled": true,
		},
	}

	// Apply terraform
	terraform.InitAndApply(t, terraformOptions)

	// Pull rendered config to validate it's content
	output := terraform.Output(t, terraformOptions, "rendered")
	assert.NotNil(t, output)
}
