FROM alpine:edge

RUN apk add --update \
    && apk add exim \
    && rm -f /var/cache/apk/*
   
RUN mkdir -p /usr/lib/exim/ /var/log/exim 

VOLUME ["/var/log/exim"]

ENTRYPOINT ["exim"]
CMD ["-bdf", "-v", "-q30m"]
