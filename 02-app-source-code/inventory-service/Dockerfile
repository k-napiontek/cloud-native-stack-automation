    FROM golang:1.26-alpine AS builder

    WORKDIR /app
   
    RUN adduser \
        --disabled-password \
        --gecos "" \
        --home "/nonexistent" \
        --shell "/sbin/nologin" \
        --no-create-home \
        --uid 10001 \
        appuser
    
    COPY go.mod go.sum ./
    RUN go mod download
    
    COPY . .
    
    RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /go/bin/myapp .
    
    FROM scratch
    
    COPY --from=builder /etc/passwd /etc/passwd
    COPY --from=builder /etc/group /etc/group
    
    COPY --from=builder /go/bin/myapp /myapp
    
    USER appuser:appuser
    
    EXPOSE 8082
    
    ENTRYPOINT ["/myapp"]