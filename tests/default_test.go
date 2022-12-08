package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestDefaultConfig(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars:         map[string]interface{}{},
	}

	// Apply terraform
	terraform.InitAndApply(t, terraformOptions)
}
