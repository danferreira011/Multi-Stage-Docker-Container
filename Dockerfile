FROM golang:1.18.10 AS build
WORKDIR /build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM alpine:3.23.2 AS app
WORKDIR /app
RUN apk add --no-cache ca-certificates
COPY --from=build /build/main .
EXPOSE 8080
CMD ["./main"]