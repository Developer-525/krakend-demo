ARG GOLANG_VERSION
ARG ALPINE_VERSION
FROM golang:${GOLANG_VERSION}-alpine${ALPINE_VERSION} as builder

RUN apk add --no-cache git

RUN apk --no-cache --virtual .build-deps add make gcc musl-dev binutils-gold

COPY . /app
WORKDIR /app

RUN make build


FROM alpine:${ALPINE_VERSION}

LABEL maintainer="community@krakend.io"

RUN apk add --no-cache ca-certificates tzdata && \
    mkdir /etc/krakend && \
    echo '{ "version": 3 }' > /etc/krakend/krakend.tmpl

COPY --from=builder /app/krakend /etc/krakend

WORKDIR /etc/krakend

CMD [ "run", "-c", "/etc/krakend/krakend.tmpl" ]

EXPOSE 8000 8090
