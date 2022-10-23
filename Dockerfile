# Multistage Go build
FROM golang:1.19.2-alpine3.16 AS builder
RUN apk add --no-cache git
WORKDIR /go/src/github.com/mkm29/order-svc/
ENV GO111MODULE=on
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix nocgo -o /app ./cmd/main.go

# Final image
FROM alpine:3.16
LABEL maintainer="Mitch Murphy <mitch.murphy@gmail.com>" \
  version="0.2.1" \
  description="Order service for Go gRPC demo"
ARG DB_HOST="db"
ARG DB_PORT="5432"
ARG DB_DATABASE="order_svc"
ARG DB_USERNAME
ARG DB_PASSWORD
COPY --from=builder /app /order-svc/
COPY --from=builder /go/src/github.com/mkm29/order-svc/pkg/config/envs/ /order-svc/
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /
RUN apk add --no-cache bash && chmod +x /wait-for-it.sh
ENV DB_HOST=$DB_HOST \
  DB_PORT=$DB_PORT \
  DB_USERNAME=$DB_USERNAME \
  DB_PASSWORD=$DB_PASSWORD \
  DB_DATABASE=$DB_DATABASE
EXPOSE 50053
# ENTRYPOINT ["/order-svc/app"]
CMD ["./wait-for-it.sh", "db:5432", "--" , "./order-svc/app"]
