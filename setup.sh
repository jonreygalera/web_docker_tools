#!/bin/bash
WORK_DIR=$PWD
DOCKER_TEMPLATES_DIR=$WORK_DIR/docker_templates
REPOSITORIES_DIR=$WORK_DIR/repositories
REPOSITORIES_DIR=$WORK_DIR/repositories
CONFIG_DIR=$WORK_DIR/configurations
HTTPD_CONF_DIR=$CONFIG_DIR/httpd_conf
CORE_DIR=$WORK_DIR/core

# Option Tools
OPTION_ALL=all
OPTION_DEFAULT=default
OPTION_NGINX=nginx
OPTION_MARIADB=mariadb
OPTION_REDIS=redis

# Action
ACTION_INSTALL=install
ACTION_LARAVEL=laravel

# Tools Dir
NGINX_DIR=$WORK_DIR/tools/$OPTION_NGINX 
REDIS_DIR=$WORK_DIR/tools/$OPTION_REDIS
MARIADB_DIR=$WORK_DIR/tools/$OPTION_MARIADB

VERSION_MARIADB=10.4
VERSION_REDIS=6.4
VERSION_DOCKER=3.7

SUFFIX_MARIADB="10_4"
SUFFIX_REDIS="6_4"


# Display
displayTools() {
  echo "Select a tools:"
  echo "[0] $OPTION_ALL"
  echo "[1] $OPTION_NGINX"
  echo "[2] $OPTION_MARIADB"
  echo "[3] $OPTION_REDIS"
  echo "[4] $OPTION_DEFAULT"
  echo "[q] exit"
}

displayActions() {
  echo "Select an action:"
  echo "[0] $ACTION_INSTALL tools"
  echo "[1] Create $ACTION_LARAVEL project"
  echo "[q] exit"
}

# Tools

dockerBuild() {
  echo "[Building]"
  docker compose up -d --build
}

runNginx() {
  echo "[$OPTION_NGINX setup]"
  cd $NGINX_DIR
  DOCKER_COMPOSE=$NGINX_DIR/docker-compose.yml
  DOCKER_COMPOSE_SETUP=$NGINX_DIR/docker-compose.setup
  cp $DOCKER_COMPOSE_SETUP $DOCKER_COMPOSE
  sed -i "s/<docker_version>/$VERSION_DOCKER/g" $DOCKER_COMPOSE
  dockerBuild
}

runMariadb() {
  echo "[$OPTION_MARIADB setup]"

  echo "Image Version:" 
  read image_version
  lowercase_string=$(echo "$image_version" | tr '[:upper:]' '[:lower:]')
  suffix=$(echo "$lowercase_string" | sed -E 's/[^a-z0-9]+/-/g')

  DIRECTORY=$WORK_DIR/tools/$OPTION_MARIADB 
  cd $MARIADB_DIR
  DOCKER_COMPOSE=$MARIADB_DIR/docker-compose.yml
  DOCKER_COMPOSE_SETUP=$MARIADB_DIR/docker-compose.setup
  cp $DOCKER_COMPOSE_SETUP $DOCKER_COMPOSE
  sed -i "s/<docker_version>/$VERSION_DOCKER/g" $DOCKER_COMPOSE
  sed -i "s/<version>/$image_version/g" $DOCKER_COMPOSE
  sed -i "s/<suffix>/$suffix/g" $DOCKER_COMPOSE
  dockerBuild
}

runRedis() {
  echo "[$OPTION_REDIS setup]"
  
  echo "Image Version:" 
  read image_version
  lowercase_string=$(echo "$image_version" | tr '[:upper:]' '[:lower:]')
  suffix=$(echo "$lowercase_string" | sed -E 's/[^a-z0-9]+/-/g')

  cd $REDIS_DIR
  DOCKER_COMPOSE=$REDIS_DIR/docker-compose.yml
  DOCKER_COMPOSE_SETUP=$REDIS_DIR/docker-compose.setup
  cp $DOCKER_COMPOSE_SETUP $DOCKER_COMPOSE
  sed -i "s/<docker_version>/$VERSION_DOCKER/g" $DOCKER_COMPOSE
  sed -i "s/<version>/$image_version/g" $DOCKER_COMPOSE
  sed -i "s/<suffix>/$suffix/g" $DOCKER_COMPOSE
  dockerBuild
}

runAll() {
  runNginx
  runMariadb
  runRedis
}

runDefault() {
  runNginx
  runMariadb
}


mainAction() {
  displayActions

  while true; 
  do
    read -n 1 -p "Enter your choice:" choice
    echo ""
    case $choice in
      0)
        mainSetup
        break ;;
      1)
        createProject $ACTION_LARAVEL
        break;;
      Q|q)
        echo "Exiting..."
        break;;
      *)
        echo "Invalid choice"
        break;;
    esac 
  done
}

mainSetup() {
  echo "Docker Version:" 
  read VERSION_DOCKER

  displayTools

  while true; 
  do
    read -n 1 -p "Enter your choice:" choice
    echo ""
    case $choice in
      0)
        runAll
        break ;;
      1)
        runNginx
        break;;
      2)
        runMariadb
        break;;
      3)
        runAll
        break;;
      4)
        runDefault
        break;;
      Q|q)
        echo "Exiting..."
        break;;
      *)
        echo "Invalid choice"
        break;;
    esac 
  done
}

createRepositoryDir() {
  echo $1
  if [ ! -d "$1" ]; then
    mkdir "$1"
  else
      echo "Directory '$1' already exists."
      exit;
  fi
}

createProject() {

  while true; do
    # Prompt the user to enter the input string
      echo "Project name (no space):" 
      read input_string

    # Check if the input is blank
    if [ -z "$input_string" ]; then
      echo "Input cannot be blank. Please try again."
    else
      lowercase_string=$(echo "$input_string" | tr '[:upper:]' '[:lower:]')
      final_string=$(echo "$lowercase_string" | sed -E 's/[^a-z0-9]+/-/g')
      break
    fi
  done

  case $1 in
    $ACTION_LARAVEL)
    createLaravel $final_string
  esac

  echo "build your project then restart nginx"
}

createLaravel() {
  php -v || echo "php not found"
  composer -V || echo "composer not found"
  cd $REPOSITORIES_DIR
  REPOSITORY_DIR="$REPOSITORIES_DIR/$1"
  createRepositoryDir $REPOSITORY_DIR
  cd $REPOSITORY_DIR
  cp $DOCKER_TEMPLATES_DIR/laravel/* ./
  cp $DOCKER_TEMPLATES_DIR/laravel/.dockerignore ./.dockerignore

  sed -i "s/<container_name>/$1/g" ./Dockerfile 
  sed -i "s/<container_name>/$1/g" ./docker-compose.yml 

  cp $REPOSITORIES_DIR/config/template.code-workspace "$1.code-workspace"
  copyConfigurations $1 $REPOSITORY_DIR

  cd $REPOSITORY_DIR
  composer create-project laravel/laravel src
  rm -rf $REPOSITORY_DIR/src/vendor

  echo "cd $REPOSITORY_DIR"
}

copyConfigurations() {
  cp -r  $CONFIG_DIR $2
  mv $2/configurations $2/playbook
  mv $2/playbook/httpd_conf/website.conf $2/playbook/httpd_conf/$1.conf
  sed -i "s/<server_name>/$1/g" $2/playbook/httpd_conf/$1.conf
  createProjectApache $1
}

createProjectApache() {
  SERVER_NAME=$1
  cd $NGINX_DIR/conf.d
  cp website.conf.template $SERVER_NAME.conf
  sed -i "s/<server_name>/$SERVER_NAME/g" $SERVER_NAME.conf

  addToHost $1
}

addToHost() {

  if [[ "$(uname)" == *MINGW* ]]; then
    host="127.0.0.1 $1.local"
    hostsFile="c/Windows/System32/drivers/etc/hosts"
    echo "Append to $hostsFile as admin"
    echo $host
  else
    echo "Not running on Windows"
  fi

}

# Main function
main() {
  # Check if Docker is installed
  if ! command -v docker &> /dev/null; then
      echo "Docker is not installed. Please install Docker."
      exit 1
  fi

  # Check if Docker is running
  if ! docker info &> /dev/null; then
    echo "Docker is not running. Please start Docker."
    exit 1
  fi

  while true;do
    echo "ctrl c to exit"
    mainAction
  done
}

main
