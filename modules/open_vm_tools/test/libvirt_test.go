package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func Test(t *testing.T) {
	terraformDir := test_structure.CopyTerraformFolderToTemp(t, "../../../", "modules/open_vm_tools/test/fixtures")
	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		Logger:       logger.New(logger.Discard),
		Vars:         map[string]interface{}{},
	}

	// Apply terraform
	terraform.InitAndApplyAndIdempotent(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)

	// Pull rendered config to validate it's content
	output := terraform.Output(t, terraformOptions, "ignition")
	require.NotNil(t, output)

	t.Run("test_output", func(t *testing.T) {
		assert.Contains(t, output, "open_vm_tools", "open-vm-tools should be enabled")
	})
}
