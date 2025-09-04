FROM alpine:edge

RUN apk add --no-cache exim \
                       ca-certificates \
                       unbound-libs \
                       tzdata \
                       exim-dnsdb \
 && mkdir -p /var/log/exim /run/exim /etc/exim /etc/tls

RUN exim --version \
 && exim -be '${lookup dnsdb{txt=example.com}{$value}fail}' | grep -qv '^fail$'

VOLUME ["/var/log/exim"]

EXPOSE 25 465 587

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
  CMD nc -z localhost 25 || exit 1

ENTRYPOINT ["exim"]

CMD ["-bd", "-q30m", "-oP", "/run/exim/exim.pid"]
