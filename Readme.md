# EcoStream

---

:warning:
**This project was originally hosted on GitLab and moved to GitHub when I reached GitLab's free tier limit.**
**I have left the .gitlab-ci.yml files as is, most of the instructions to deploy the application will not work because they rely on GitLab's services (e.g. container registries)**

**TODO: update all EcoStream repositories to use GitHub actions and some independent container registry instead of GitLab services.**

---


This app shows air quality data in French cities.
Data comes from The World Health Organization (WHO) https://www.who.int/data/gho/data/themes/air-pollution/who-air-quality-database/2022.

The "air quality score" represented here is custom, we wanted to use the Air Quality Index (AQI) at first, but when we calculated it from the values of the WHO data, it was not representative of the actual air quality, because the WHO data provides an average value of gas concentration in the air over the year whereas the air quality index should be calculated based on gas concentrations measured during daily peak periods.

The custom air quality index calculated in this project is supposed to be more representative of the actual air quality in the listed cities over the years.

![EcoStream main page](ecostream_main_page.png)
EcoStream main page showing the air quality scores in the city of Rennes, France over a few years.

## Project structure

EcoStream services and utility components are separated into multiple repositories:
- [EcoStream Visualizer](https://github.com/guillaume-kermorgant/EcoStream-visualizer): the EcoStream frontend built with React.js
- [EcoStream Manager](https://github.com/guillaume-kermorgant/EcoStream-manager): the EcoStream backend built with Node.js
- [EcoStream Database](https://github.com/guillaume-kermorgant/EcoStream-database): a PostgreSQL database used to store EcoStream data
- [EcoStream Environment Setup](https://github.com/guillaume-kermorgant/EcoStream-environment-setup): a repository containing resources to easily deploy EcoStream on the cloud
- [EcoStream GitOps](https://github.com/guillaume-kermorgant/EcoStream-gitops): ArgoCD resources that allow to deploy EcoStream
- [EcoStream CICD](https://github.com/guillaume-kermorgant/EcoStream-CICD): CICD resources (e.g. GitOps update script)


## Run EcoStream locally for development

See Readmes from ecostream-manager, ecostream-visualizer and ecostream-database repos.

## [Deprecated] Run EcoStream locally with Terraform and Docker

Deprecated: uses GitLab services

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

## Run EcoStream on Minikube (not working correctly on macOS)

This is not working for now because of failure in ingress management when running minikube on my mac (M3).

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

The base images have been pulled from Docker Hub and pushed to this project's container registry with the Gitlab CI pipeline configured in .gitlab-ci.yml file in this repo.

For now, only amd64 base images are used as we configure amd64 nodes for our test EKS cluster. We could also pull arm64 images if needed.

In this pipeline, we also manage an other image:
- a bitnami/kubectl image that we use in our configuration job (a K8S job that deploys a few configuration resource e.g. a ConfigMap containing components URLs)
- an alpine-ansible image used to run our Ansible playbooks
- an ubuntu image used in our CICD pipeline
- an alpine image which is very basic and embeds a few dependencies used by some of our configuration K8S Jobs