FROM golang:1.26.3-alpine AS builder

WORKDIR /src

# Download dependencies first to cache this layer
COPY go.mod go.sum ./
RUN go mod download

# We need tzdata, ca-certificates, and git to download error pages
RUN apk add --no-cache ca-certificates tzdata git

# Clone just the gh-pages branch into a temporary directory
RUN git clone --depth 1 --branch gh-pages --single-branch https://github.com/tarampampam/error-pages.git /tmp/error-pages

# Copy source and build
COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /usr/bin/caddy main.go

# Final stage
FROM scratch

# Configure standard XDG Base Directories for Caddy
ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

# Copy over the certificates and timezone data
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

# Copy the requested error pages directly from builder's git clone
COPY --from=builder /tmp/error-pages/lost-in-space /srv/error-pages

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

# Set default command for caddy-docker-proxy
CMD ["caddy", "docker-proxy"]
