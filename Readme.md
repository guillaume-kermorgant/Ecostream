# EcoStream

## Base images

Base images are stored in this project's container registry.
They have been pulled from docker hub and then built and pushed manually with the following commands (amd64 and arm64):

- Node:

```
docker pull --platform=linux/amd64 node:22.12
docker save node:22.12 -o node-22.12-amd64.tar
docker pull --platform=linux/arm64 node:22.12
docker save node:22.12 -o node-22.12-arm64.tar
docker load -i node-22.12-amd64.tar
docker tag node:22.12 registry.gitlab.com/gkermo/ecostream/base_images/node:22.12-amd64
docker load -i node-22.12-arm64.tar
docker tag node:22.12 registry.gitlab.com/gkermo/ecostream/base_images/node:22.12-arm64
docker push registry.gitlab.com/gkermo/ecostream/base_images/node:22.12-amd64
docker push registry.gitlab.com/gkermo/ecostream/base_images/node:22.12-arm64
```

- Nginx:

```
docker pull --platform=linux/amd64 nginx:1.27.3-alpine
docker save nginx:1.27.3-alpine -o nginx:1.27.3-alpine-amd64.tar
docker pull --platform=linux/arm64 nginx:1.27.3-alpine
docker save nginx:1.27.3-alpine -o nginx:1.27.3-alpine-arm64.tar
docker load -i nginx:1.27.3-alpine-amd64.tar
docker tag nginx:1.27.3-alpine registry.gitlab.com/gkermo/ecostream/base_images/nginx:1.27.3-alpine-amd64
docker load -i nginx:1.27.3-alpine-arm64.tar
docker tag nginx:1.27.3-alpine registry.gitlab.com/gkermo/ecostream/base_images/nginx:1.27.3-alpine-arm64
docker push registry.gitlab.com/gkermo/ecostream/base_images/nginx:1.27.3-alpine-amd64
docker push registry.gitlab.com/gkermo/ecostream/base_images/nginx:1.27.3-alpine-arm64
```

## Run locally

### EcoStream Manager

- pull the repo:

```
git clone git@gitlab.com:gkermo/ecostream-manager.git
```

- run the manager:

```
cd ./ecostream-manager
npm ci
npm start
# dev env var can be found in .env file
# test request:
curl http://manager:manager-password@localhost:6850/api/v1/aqi\?city\=paris
```

### EcoStream Visualizer

- pull the repo:

```
git clone git@gitlab.com:gkermo/ecostream-visualizer.git
```

- run the proxy backend:

```
cd ./ecostream-visualizer
cd ./proxy-backend
npm ci
npm start
```

- run the visualizer:

```
cd ./ecostream-visualizer
cd ./visualizer
npm ci
export REACT_ACT_PROXY_BACKEND_URL="http://localhost:3000"
npm start
```

## Run locally with Docker

See Readmes in ecostream-visualizer and ecostream-manager repos

## Run on minikube

TODO