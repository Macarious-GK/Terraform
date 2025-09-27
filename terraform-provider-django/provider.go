package main

import (
	"context"
	"net/http"
	"strings"
	"time"

	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
)

func provider() *schema.Provider {
	return &schema.Provider{
		Schema: map[string]*schema.Schema{
			"base_url": {
				Type:        schema.TypeString,
				Required:    true,
				Description: "Base URL of the backend API, e.g., http://127.0.0.1:8000/api",
			},
			"token": {
				Type:        schema.TypeString,
				Optional:    true,
				Sensitive:   true,
				Description: "Optional bearer token for API auth",
			},
		},
		ResourcesMap: map[string]*schema.Resource{
			"mybackend_project": resourceProject(),
		},
		ConfigureContextFunc: providerConfigure,
	}
}

func providerConfigure(ctx context.Context, d *schema.ResourceData) (interface{}, diag.Diagnostics) {
	var diags diag.Diagnostics

	baseURL := d.Get("base_url").(string)
	baseURL = strings.TrimRight(baseURL, "/")

	token := ""
	if v, ok := d.GetOk("token"); ok {
		token = v.(string)
	}

	client := &Client{
		BaseURL:    baseURL,
		Token:      token,
		HTTPClient: newHTTPClient(10 * time.Second),
	}
	return client, diags
}

func newHTTPClient(timeout time.Duration) *http.Client {
	return &http.Client{Timeout: timeout}
}
