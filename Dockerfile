FROM golang:alpine as build

RUN apk add libcap

WORKDIR /src

ADD . /src

RUN go mod tidy
RUN CGO_ENABLED=0 go build -o /app main.go
RUN setcap 'cap_net_bind_service=+ep' /app

FROM gcr.io/distroless/static AS final

USER nonroot:nonroot
COPY --from=build --chown=nonroot:nonroot /app /app
COPY --from=build --chown=nonroot:nonroot /var /dnslog

WORKDIR /
ENTRYPOINT ["/app"]



