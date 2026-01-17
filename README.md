# Multi-Stage Docker Container

Uma aplicação Go simples que demonstra a construção de imagens Docker otimizadas usando **multi-stage builds**.

## 📋 Sobre a Aplicação

A aplicação é um servidor HTTP simples que roda na porta **8080** e exibe uma página de teste em HTML.

```go
func hello(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "<h1>Página de teste</h1>")
}
```

## 🐳 Sobre o Dockerfile

### Dockerfile (Multi-Stage) - Recomendado

O `Dockerfile` utiliza a estratégia de **multi-stage build**, que reduz significativamente o tamanho da imagem final:

```dockerfile
# Stage 1: Build
FROM golang:1.18.10 AS build
WORKDIR /build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Stage 2: Runtime
FROM alpine:3.23.2 AS app
WORKDIR /app
RUN apk add --no-cache ca-certificates
COPY --from=build /build/main .
EXPOSE 8080
CMD ["./main"]
```

**Vantagens:**
- ✅ Imagem final muito menor (~15MB vs ~900MB)
- ✅ Separação clara entre build e runtime
- ✅ Menor superfície de ataque (apenas Alpine Linux)
- ✅ Mais rápido para deploy

### Dockerfile.alpine - Single-Stage Otimizado

O `Dockerfile.alpine` é uma versão **single-stage** que utiliza a base Alpine Linux, oferecendo um bom equilíbrio entre simplicidade e tamanho:

```dockerfile
FROM golang:tip-alpine3.23
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .
CMD [ "./main" ]
```

**Características:**
- ✅ Mais simples que multi-stage (apenas um estágio)
- ✅ Imagem compacta (~150MB)
- ✅ Melhor que o Dockerfile simples, mas maior que o multi-stage
- ⚠️ Inclui ferramentas de build (menos seguro que multi-stage)

### Dockerfile.simples - Alternativa

O `Dockerfile.simples` é uma versão single-stage mais simples, mas produz uma imagem muito maior.

## 🚀 Como Rodar

### Opção 1: Com o Dockerfile Multi-Stage (Recomendado)

```bash
# Construir a imagem
docker build -t app-multi-stage:latest .

# Rodar o container
docker run -d -p 8080:8080 app-multi-stage:latest
```

### Opção 2: Com o Dockerfile Alpine (Single-Stage)

```bash
# Construir a imagem
docker build -f Dockerfile.alpine -t app-alpine:latest .

# Rodar o container
docker run -d -p 8080:8080 app-alpine:latest
```

### Opção 3: Com o Dockerfile Simples

```bash
# Construir a imagem
docker build -f Dockerfile.simples -t app-simples:latest .

# Rodar o container
docker run -d -p 8080:8080 app-simples:latest
```

## 🧪 Testando a Aplicação

Após iniciar o container, acesse a aplicação:

```bash
# No navegador
http://localhost:8080

# Ou via curl
curl http://localhost:8080
```

Você deve ver a resposta:
```html
<h1>Página de teste</h1>
```

## 📊 Comparação de Tamanho

| Dockerfile | Tamanho da Imagem |
|-----------|-------------------|
| Multi-Stage | ~15 MB |
| Alpine | ~150 MB |
| Simples (Golang) | ~900 MB |

**Recomendação:** Use `Dockerfile` (multi-stage) para produção! 🚀

## 🛠️ Outros Comandos Úteis

```bash
# Listar containers
docker ps -a

# Ver logs do container
docker logs <container-id>

# Parar o container
docker stop <container-id>

# Remover a imagem
docker rmi app-multi-stage:latest
```

## 📝 Notas Importantes

- A aplicação escuta na porta **8080**
- O Dockerfile multi-stage usa `CGO_ENABLED=0` para compilação estática
- Alpine Linux é usado como imagem base (muito menor que golang)
- O certificado CA é instalado para suportar requisições HTTPS (se necessário)

## 👤 Variações com Docker Hub

Se quiser fazer push para o Docker Hub:

```bash
# Construir com seu usuário Docker
docker build -t <seu-usuario>/app-multi-stage:latest .

# Fazer login no Docker Hub
docker login

# Fazer push
docker push <seu-usuario>/app-multi-stage:latest
```
