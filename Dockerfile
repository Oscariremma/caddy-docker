FROM golang:1.26.0-alpine AS builder

WORKDIR /src

# Download dependencies first to cache this layer
COPY go.mod go.sum ./
RUN go mod download

# We need tzdata and ca-certificates for scratch
RUN apk add --no-cache ca-certificates tzdata

# Copy source and build
COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /usr/bin/caddy main.go

# Final stage
FROM scratch

# Copy over the certificates and timezone data
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Set default command for caddy-docker-proxy
CMD ["caddy", "docker-proxy"]
