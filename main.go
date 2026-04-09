package main

import (
	cmd "github.com/caddyserver/caddy/v2/cmd"
	_ "github.com/caddyserver/caddy/v2/modules/standard"

	_ "github.com/caddy-dns/cloudflare"
	_ "github.com/lucaslorentz/caddy-docker-proxy/v2"
)

func main() {
	cmd.Main()
}
