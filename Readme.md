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
npm start
```

## Run on minikube


TODO