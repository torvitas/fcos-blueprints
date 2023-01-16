package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func Test(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "fixtures",
		Vars:         map[string]interface{}{},
	}

	// Apply terraform
	terraform.InitAndApplyAndIdempotent(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)

	// ipAddress := terraform.Output(t, terraformOptions, "rendered")
}
