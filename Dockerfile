FROM golang:1.12 as build
MAINTAINER Will Norris <will@willnorris.com>

RUN useradd -u 1001 go

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -v ./cmd/imageproxy

FROM alpine

COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /app/imageproxy /app/imageproxy

USER go

CMD ["-addr", "0.0.0.0:8080"]
ENTRYPOINT ["/app/imageproxy", "-cache", "/tmp/imageproxy"]

EXPOSE 8080
