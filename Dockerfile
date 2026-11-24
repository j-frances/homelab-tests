FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update && apt-get install -y xz-utils

# Copy the static mise binary from the official image
COPY --from=jdxcode/mise:latest /usr/local/bin/mise /usr/local/bin/mise

# Copy your tool configuration and install globally
COPY mise.toml /tmp/mise.toml
RUN cd /tmp && mise trust && mise install --system --yes

# Add mise shims to the default PATH
ENV PATH="/usr/local/share/mise/shims:${PATH}"