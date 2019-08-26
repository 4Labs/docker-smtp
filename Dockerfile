FROM namshi/smtp

COPY entrypoint-with-secrets.sh /entrypoint-with-secrets.sh

RUN chmod a+x /entrypoint-with-secrets.sh

ENV DOCKER_ORIGINAL_ENTRYPOINT /bin/entrypoint.sh

ENTRYPOINT ["/entrypoint-with-secrets.sh"]

CMD ["exim", "-bd", "-q15m", "-v"]
