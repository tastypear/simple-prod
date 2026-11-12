FROM debian:latest

ARG TTYD_VERSION=1.7.8
ARG HANDY_SSHD_VERSION=0.5.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN set -eux; \
    arch="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "$arch" in \
        amd64) ttyd_arch=x86_64; cf_arch=amd64 ;; \
        arm64) ttyd_arch=aarch64; cf_arch=arm64 ;; \
        *) echo "unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/tastypear/ttyd/releases/download/${TTYD_VERSION}/ttyd.${ttyd_arch}" -o ttyd; \
    curl -fsSL "https://github.com/tastypear/handy-sshd/releases/download/v${HANDY_SSHD_VERSION}/handy-sshd-${HANDY_SSHD_VERSION}-linux-${arch}.tar.gz" -o /tmp/handy-sshd.tar.gz; \
    tar -xzf /tmp/handy-sshd.tar.gz -C /tmp; \
    cp "/tmp/handy-sshd-${HANDY_SSHD_VERSION}-linux-${arch}/handy-sshd" .; \
    rm -rf /tmp/handy-sshd.tar.gz "/tmp/handy-sshd-${HANDY_SSHD_VERSION}-linux-${arch}"; \
    curl -fsSL "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${cf_arch}" -o cloudflared; \
    chmod +x ttyd handy-sshd cloudflared

COPY start.sh .
RUN chmod +x start.sh

ENV PORT=7681
EXPOSE 7681

ENTRYPOINT ["./start.sh"]
