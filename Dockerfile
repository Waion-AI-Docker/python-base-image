# Python Base Image - Alpine optimized with uv
# Provides a secure, minimal base for Python applications

FROM python:3.12-alpine

# Security labels
LABEL org.opencontainers.image.title="Python Base Image" \
      org.opencontainers.image.description="Secure, minimal Python base image with uv" \
      org.opencontainers.image.vendor="Waion AI Infrastructure"

# Install tini, build deps, and apply security updates
RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache tini && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Create non-root user for security
RUN addgroup -g 1001 -S python && \
    adduser -S python -u 1001 -G python -h /app -s /sbin/nologin

# Security: Set restrictive umask
RUN echo "umask 027" >> /etc/profile

# Set working directory
WORKDIR /app

# Set ownership to non-root user
RUN chown -R python:python /app

# Environment hardening
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    HOME=/app

# Switch to non-root user
USER python

# Use tini as PID 1 for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Default command (can be overridden)
CMD ["python"]
