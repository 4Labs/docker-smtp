FROM namshi/smtp

COPY entrypoint-with-secrets.sh /entrypoint-with-secrets.sh

ENV DOCKER_ORIGINAL_ENTRYPOINT /bin/entrypoint.sh

ENTRYPOINT /entrypoint-with-secrets.sh
