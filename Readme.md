# EcoStream

This app shows air quality data in French cities.
Data comes from The World Health Organization (WHO) https://www.who.int/data/gho/data/themes/air-pollution/who-air-quality-database/2022.

The "air quality score" represented here is custom, we wanted to use the Air Quality Index (AQI) at first, but when we calculated it from the values of the WHO data, it was not representative of the actual air quality, because the WHO data provides an average value of gas concentration in the air over the year whereas the air quality index should be calculated based on gas concentrations measured during daily peak periods.

The custom air quality index calculated in this project is supposed to be more representative of the actual air quality in the listed cities over the years.

![EcoStream main page](ecostream_main_page.png)
EcoStream main page showing the air quality scores in the city of Rennes, France over a few years.

## Project structure

EcoStream services and utility components are separated into multiple repositories:
- [EcoStream Visualizer](https://gitlab.com/gkermo/ecostream-visualizer): the EcoStream frontend built with React.js
- [EcoStream Manager](https://gitlab.com/gkermo/ecostream-manager): the EcoStream backend built with Node.js
- [EcoStream Database](https://gitlab.com/gkermo/ecostream-database): a PostgreSQL database used to store EcoStream data
- [EcoStream Environment Setup](https://gitlab.com/gkermo/ecostream-environment-setup): a repository containing resources to easily deploy EcoStream on the cloud
- [EcoStream GitOps](https://gitlab.com/gkermo/ecostream-gitops): ArgoCD resources that allow to deploy EcoStream


## Run EcoStream locally for development

See Readmes from ecostream-manager, ecostream-visualizer and ecostream-database repos.

## Run EcoStream locally with Terraform and Docker

You can deploy EcoStream locally with the Terraform script from this repo.

You must first export your GitLab credentials, and then run tofu/terraform commands:

```
export GITLAB_USERNAME=
export GITLAB_TOKEN=
# pull the latest docker images (updates local images)
docker pull registry.gitlab.com/gkermo/ecostream-manager:latest-amd64
docker pull registry.gitlab.com/gkermo/ecostream-visualizer:latest-amd64
registry.gitlab.com/gkermo/ecostream-database:latest-amd64
# generate local_run.tfvars with gitlab credentials
envsubst < template.tfvars > local_run.tfvars
tofu init
tofu apply -var-file="local_run.tfvars"
```

- Check that the EcoStream Manager is working:

```
curl http://manager:manager-password@localhost:9000/api/v1/aqi\?city\=paris
```

- Open http://localhost:3000 in your browser

You should see the EcoStream app but there should not be any data

- add some data using the script from ecostream-database repo:

```
# navigate to ecostream-database repo
cd ecostream-database/data
# export ecostream manager connection information and execute the script to populate the DB
export ECOSTREAM_MANAGER_URL=http://localhost:9000
export ECOSTREAM_MANAGER_USERNAME=manager
export ECOSTREAM_MANAGER_PASSWORD=manager-password
./populate_ecostream_db.sh
```

- reload the EcoStream app in your browser, you should see some data now!

- destroy ecostream instance:

```
tofu destroy -var-file="local_run.tfvars"
```

## Run EcoStream on Minikube (not working correctly)

This is not working for now because of failure in ingress management when running minikube on my mac (M3).
I could have tried to run it on a Linux VM (for instance) but I did not want to spend more time on that.

- start minikube:

```
minikube start
```

- Use the helm Chart present in the ecostream-gitops repo under ./helm-chart

```
cd ecostream-gitops/helm-chart
helm install ecostream ./
```

Be aware that the ingress might not work as expected with minikube, see https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/.

Easiest way is to expose the visualizer app manually:

```
minikube service ecostream-visualizer-service --url -n ecostream
```
... and open displayed URL (something like http://127.0.0.1:55364)
but then it is not going to work because the visualizer won't be able to access the manager's ingress.

## Base images

Base images used by EcoStream services are stored in this project's container registry.
Whenever we create a new project that needs access to this container registry, we need to add that new project to the allowlist of this project from Gitlab UI Settings -> CI/CD -> Job token permissions

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

- PostgreSQL:

```
docker pull --platform=linux/amd64 postgres:17.4
docker save postgres:17.4 -o postgres:17.4-amd64.tar
docker pull --platform=linux/arm64 postgres:17.4
docker save postgres:17.4 -o postgres:17.4-arm64.tar
docker load -i postgres:17.4-amd64.tar
docker tag postgres:17.4 registry.gitlab.com/gkermo/ecostream/base_images/postgres:17.4-amd64
docker load -i postgres:17.4-arm64.tar
docker tag postgres:17.4 registry.gitlab.com/gkermo/ecostream/base_images/postgres:17.4-arm64
docker push registry.gitlab.com/gkermo/ecostream/base_images/postgres:17.4-amd64
docker push registry.gitlab.com/gkermo/ecostream/base_images/postgres:17.4-arm64

- Open Tofu (used by Gitlab CI):

The OpenTofu image used in this pipeline is stored in gkermo/ecostream gitlab container registry, in order to avoid the existing pull rate limitation from docker hub.

Here is the process to follow in order to pull a gitlab-opentofu image from dockerhub and push it to gkermo/ecostream container registry.

```
docker pull --platform=linux/amd64 registry.gitlab.com/components/opentofu/gitlab-opentofu:1.1.0-opentofu1.9.0-alpine
docker save registry.gitlab.com/components/opentofu/gitlab-opentofu:1.1.0-opentofu1.9.0-alpine -o gitlab-opentofu:1.1.0-opentofu1.9.0-alpine-amd64.tar
docker load -i gitlab-opentofu:1.1.0-opentofu1.9.0-alpine-amd64.tar
docker tag registry.gitlab.com/components/opentofu/gitlab-opentofu:1.1.0-opentofu1.9.0-alpine registry.gitlab.com/gkermo/ecostream/opentofu/gitlab-opentofu:1.1.0-opentofu1.9.0-alpine-amd64
docker push registry.gitlab.com/gkermo/ecostream/opentofu/gitlab-opentofu:1.1.0-opentofu1.9.0-alpine-amd64
```
