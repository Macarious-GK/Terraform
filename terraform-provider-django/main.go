package main

import (
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/hashicorp/terraform-plugin-sdk/v2/plugin"
)

func main() {
	// Serve the provider to Terraform.
	plugin.Serve(&plugin.ServeOpts{
		ProviderFunc: func() *schema.Provider {
			p := provider()
			return p
		},
	})
}
