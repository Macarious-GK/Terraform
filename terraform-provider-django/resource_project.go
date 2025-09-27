package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
)

func resourceProject() *schema.Resource {
	return &schema.Resource{
		CreateContext: resourceProjectCreate,
		ReadContext:   resourceProjectRead,
		UpdateContext: resourceProjectUpdate,
		DeleteContext: resourceProjectDelete,

		Schema: map[string]*schema.Schema{
			"name": {
				Type:     schema.TypeString,
				Required: true,
			},
			"description": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"external_id": {
				Type:     schema.TypeString,
				Computed: true,
			},
		},
	}
}

type projectRequest struct {
	Name        string `json:"name"`
	Description string `json:"description,omitempty"`
}
type projectResponse struct {
	ID          int64  `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
}

func resourceProjectCreate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	client := m.(*Client)
	var diags diag.Diagnostics

	reqBody := projectRequest{
		Name:        d.Get("name").(string),
		Description: d.Get("description").(string),
	}
	buf := new(bytes.Buffer)
	if err := json.NewEncoder(buf).Encode(reqBody); err != nil {
		return diag.FromErr(err)
	}

	url := fmt.Sprintf("%s/projects/", client.BaseURL)
	req, _ := http.NewRequestWithContext(ctx, http.MethodPost, url, buf)
	req.Header.Set("Content-Type", "application/json")
	if client.Token != "" {
		req.Header.Set("Authorization", "Bearer "+client.Token)
	}

	resp, err := client.HTTPClient.Do(req)
	if err != nil {
		return diag.FromErr(err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusCreated && resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(resp.Body)
		return diag.Errorf("create failed: status %s body: %s", resp.Status, string(b))
	}

	var pr projectResponse
	if err := json.NewDecoder(resp.Body).Decode(&pr); err != nil {
		return diag.FromErr(err)
	}

	// Set Terraform resource ID and computed fields
	d.SetId(fmt.Sprintf("%d", pr.ID))
	if err := d.Set("external_id", fmt.Sprintf("%d", pr.ID)); err != nil {
		return diag.FromErr(err)
	}

	return diags
}

func resourceProjectRead(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	client := m.(*Client)
	var diags diag.Diagnostics

	id := d.Id()
	url := fmt.Sprintf("%s/projects/%s/", client.BaseURL, id)
	req, _ := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if client.Token != "" {
		req.Header.Set("Authorization", "Bearer "+client.Token)
	}
	resp, err := client.HTTPClient.Do(req)
	if err != nil {
		return diag.FromErr(err)
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusNotFound {
		// Resource deleted externally — remove from state
		d.SetId("")
		return diags
	}
	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(resp.Body)
		return diag.Errorf("read failed: %s", string(b))
	}

	var pr projectResponse
	if err := json.NewDecoder(resp.Body).Decode(&pr); err != nil {
		return diag.FromErr(err)
	}

	_ = d.Set("name", pr.Name)
	_ = d.Set("description", pr.Description)
	_ = d.Set("external_id", fmt.Sprintf("%d", pr.ID))

	return diags
}

func resourceProjectUpdate(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	client := m.(*Client)

	id := d.Id()
	// only send changed fields — example simple PUT with full object
	reqBody := projectRequest{
		Name:        d.Get("name").(string),
		Description: d.Get("description").(string),
	}
	buf := new(bytes.Buffer)
	if err := json.NewEncoder(buf).Encode(reqBody); err != nil {
		return diag.FromErr(err)
	}

	url := fmt.Sprintf("%s/projects/%s/", client.BaseURL, id)
	req, _ := http.NewRequestWithContext(ctx, http.MethodPut, url, buf) // or PATCH
	req.Header.Set("Content-Type", "application/json")
	if client.Token != "" {
		req.Header.Set("Authorization", "Bearer "+client.Token)
	}

	resp, err := client.HTTPClient.Do(req)
	if err != nil {
		return diag.FromErr(err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(resp.Body)
		return diag.Errorf("update failed: %s", string(b))
	}

	return resourceProjectRead(ctx, d, m)
}

func resourceProjectDelete(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	client := m.(*Client)
	var diags diag.Diagnostics

	id := d.Id()
	url := fmt.Sprintf("%s/projects/%s/", client.BaseURL, id)
	req, _ := http.NewRequestWithContext(ctx, http.MethodDelete, url, nil)
	if client.Token != "" {
		req.Header.Set("Authorization", "Bearer "+client.Token)
	}

	resp, err := client.HTTPClient.Do(req)
	if err != nil {
		return diag.FromErr(err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusNoContent && resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(resp.Body)
		return diag.Errorf("delete failed: %s", string(b))
	}

	d.SetId("") // remove from state
	return diags
}
