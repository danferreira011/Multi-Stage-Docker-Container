Teste o código:<br><br>

docker build -t \<user-docker\>/app-multi-stage:multistage -f Dockerfile.multistage .<br>
docker run -d -p 8080:8080 \<user-docker\>/app-multi-stage:multistage
