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

See Readmes from ecostream

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
curl http://manager:manager-password@localhost:9000/api/v1/aqi\?city\=paris
```

### EcoStream Visualizer

- pull the repo:

```
git clone git@gitlab.com:gkermo/ecostream-visualizer.git
```

- run the visualizer:

```
cd ./ecostream-visualizer
cd ./visualizer
npm ci
export REACT_APP_ECOSTREAM_MANAGER_URL="http://host.docker.internal:9000"
export REACT_ACT_ECOSTREAM_MANAGER_USERNAME="manager"
export REACT_ACT_ECOSTREAM_MANAGER_PASSWORD="manager-password"
npm start
```

## Run locally with Terraform and Docker

You must first export your GitLab credentials, and then run terraform commands:

```
export GITLAB_USERNAME=
export GITLAB_TOKEN=
# generate local_run.tfvars with gitlab credentials
envsubst < template.tfvars > local_run.tfvars
terraform init
terraform apply -var-file="local_run.tfvars"
```

- Check that the EcoStream Manager is working:

```
curl http://manager:manager-password@localhost:9000/api/v1/aqi\?city\=paris
```

- Open http://localhost:3000 in your browser


## Run locally with Docker (not Terraform)

See Readmes in ecostream-visualizer and ecostream-manager repos

## Run on Minikube

This is not working for now because of failure in ingress management when running minikube on my mac (M3).

Use the helm Chart present in the ecostream-gitops repo under ./resources

```
helm install ecostream ./
```

Be aware that the ingress might not work as expected with minikube, see https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/.

Easiest way is to expose the visualizer app manually:

```
minikube service ecostream-visualizer-service --url -n ecostream
```
... and open displayed URL (something like http://127.0.0.1:55364)
but then it is not going to work because the visualizer won't be able to access the manager's ingress.