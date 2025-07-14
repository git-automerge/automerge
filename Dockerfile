FROM alpine:3.19

# Install required packages
RUN apk add --no-cache git bash curl

# Set working directory
WORKDIR /automerge

# Copy scripts
COPY bin/ /usr/local/bin/
COPY git-automerge.1 /usr/local/share/man/man1/

# Make scripts executable
RUN chmod +x /usr/local/bin/git-automerge


# Use wrapper as entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
