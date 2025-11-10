package database

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
)

// SupabaseClient handles interactions with Supabase
type SupabaseClient struct {
	URL        string
	AnonKey    string
	ServiceKey string
	HTTPClient *http.Client
}

// NewSupabaseClient creates a new Supabase client
func NewSupabaseClient() *SupabaseClient {
	return &SupabaseClient{
		URL:        os.Getenv("SUPABASE_URL"),
		AnonKey:    os.Getenv("SUPABASE_ANON_KEY"),
		ServiceKey: os.Getenv("SUPABASE_SERVICE_KEY"),
		HTTPClient: &http.Client{},
	}
}

// Query executes a query on a Supabase table
func (c *SupabaseClient) Query(table string, query map[string]interface{}, useServiceKey bool) ([]byte, error) {
	url := fmt.Sprintf("%s/rest/v1/%s", c.URL, table)
	
	// Build query parameters
	if len(query) > 0 {
		url += "?"
		for k, v := range query {
			url += fmt.Sprintf("%s=eq.%v&", k, v)
		}
	}
	
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}
	
	c.setHeaders(req, useServiceKey)
	
	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	
	if resp.StatusCode >= 400 {
		return nil, fmt.Errorf("supabase error: %s", string(body))
	}
	
	return body, nil
}

// Insert inserts data into a Supabase table
func (c *SupabaseClient) Insert(table string, data interface{}, useServiceKey bool) ([]byte, error) {
	url := fmt.Sprintf("%s/rest/v1/%s", c.URL, table)
	
	jsonData, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}
	
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}
	
	c.setHeaders(req, useServiceKey)
	req.Header.Set("Prefer", "return=representation")
	
	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	
	if resp.StatusCode >= 400 {
		return nil, fmt.Errorf("supabase error: %s", string(body))
	}
	
	return body, nil
}

// Update updates data in a Supabase table
func (c *SupabaseClient) Update(table string, id string, data interface{}, useServiceKey bool) ([]byte, error) {
	url := fmt.Sprintf("%s/rest/v1/%s?id=eq.%s", c.URL, table, id)
	
	jsonData, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}
	
	req, err := http.NewRequest("PATCH", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}
	
	c.setHeaders(req, useServiceKey)
	req.Header.Set("Prefer", "return=representation")
	
	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	
	if resp.StatusCode >= 400 {
		return nil, fmt.Errorf("supabase error: %s", string(body))
	}
	
	return body, nil
}

// Delete deletes data from a Supabase table
func (c *SupabaseClient) Delete(table string, id string, useServiceKey bool) error {
	url := fmt.Sprintf("%s/rest/v1/%s?id=eq.%s", c.URL, table, id)
	
	req, err := http.NewRequest("DELETE", url, nil)
	if err != nil {
		return err
	}
	
	c.setHeaders(req, useServiceKey)
	
	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	
	if resp.StatusCode >= 400 {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("supabase error: %s", string(body))
	}
	
	return nil
}

// AuthSignUp creates a new user with Supabase Auth
func (c *SupabaseClient) AuthSignUp(email, password string) ([]byte, error) {
	url := fmt.Sprintf("%s/auth/v1/signup", c.URL)
	
	data := map[string]string{
		"email":    email,
		"password": password,
	}
	
	jsonData, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}
	
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}
	
	req.Header.Set("apikey", c.AnonKey)
	req.Header.Set("Content-Type", "application/json")
	
	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	
	if resp.StatusCode >= 400 {
		return nil, fmt.Errorf("signup error: %s", string(body))
	}
	
	return body, nil
}

// AuthSignIn signs in a user with Supabase Auth
func (c *SupabaseClient) AuthSignIn(email, password string) ([]byte, error) {
	url := fmt.Sprintf("%s/auth/v1/token?grant_type=password", c.URL)
	
	data := map[string]string{
		"email":    email,
		"password": password,
	}
	
	jsonData, err := json.Marshal(data)
	if err != nil {
		return nil, err
	}
	
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		return nil, err
	}
	
	req.Header.Set("apikey", c.AnonKey)
	req.Header.Set("Content-Type", "application/json")
	
	resp, err := c.HTTPClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}
	
	if resp.StatusCode >= 400 {
		return nil, fmt.Errorf("signin error: %s", string(body))
	}
	
	return body, nil
}

// setHeaders sets common headers for Supabase requests
func (c *SupabaseClient) setHeaders(req *http.Request, useServiceKey bool) {
	if useServiceKey {
		req.Header.Set("apikey", c.ServiceKey)
		req.Header.Set("Authorization", "Bearer "+c.ServiceKey)
	} else {
		req.Header.Set("apikey", c.AnonKey)
		req.Header.Set("Authorization", "Bearer "+c.AnonKey)
	}
	req.Header.Set("Content-Type", "application/json")
}

