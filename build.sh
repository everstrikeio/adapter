docker rm -f adapter
docker build -t adapter .
docker run -it -d --name adapter adapter
