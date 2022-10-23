# Multistage Go build
FROM golang:1.19.2-alpine3.16 AS builder
RUN apk add --no-cache git
WORKDIR /go/src/github.com/mkm29/order-svc/
ENV GO111MODULE=on
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix nocgo -o /app ./cmd/main.go

# Final image
FROM alpine:3.16
COPY --from=builder /app /order-svc/
COPY --from=builder /go/src/github.com/mkm29/order-svc/pkg/config/envs/ /order-svc/
EXPOSE 50053
ENTRYPOINT ["/order-svc/app"]