FROM golang:1.23-alpine AS builder

WORKDIR /src

COPY go.* ./
RUN go mod download
COPY . ./

# Build static binary with certificates support
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags='-w -s -extldflags "-static"' \
    -a -installsuffix cgo \
    -o /bin/mediawiki_exporter

FROM alpine:3.23

RUN apk --no-cache add ca-certificates

COPY --from=builder /bin/mediawiki_exporter /bin/

EXPOSE 8000

CMD ["/bin/mediawiki_exporter"]
