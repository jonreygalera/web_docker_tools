# <span id="top">[NMS NGINX Docker](../)</span>
<br/>
NGINX Docker image setup files

## [#](#prerequisites) <span id="prerequisites">Prerequisites</span>
- [Docker](https://www.docker.com/)
## [#](#setup) <span id="setup">Setup for Development</span>
1. Clone the repository.
```sh
git clone https://nexus.nmscreative.com/creative-projects/nginx-docker.git
```
2. Rename the file `conf.d/project-url.conf.example` to your `<project url>.conf`.
>Example: local.projectname.com.conf
3. Replace all `<project-url>` to your **project url**.
```sh
server {
  listen 80;
  server_name <project-url>;
```
4. Replace all `<container-name>` to your **container name**.
```sh
  location / {
    proxy_pass         http://<container-name>;
```
5. Run the following command:
```sh
docker-compose up -d --build
```

## [#](#setup) <span id="setup">Switching Projects</span>


[Back to Top](#top)