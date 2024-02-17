#!/bin/bash
WORK_DIR=$PWD
DOCKER_TEMPLATES_DIR=$PWD/docker_templates
REPOSITORIES_DIR=$PWD/repositories

VERSION_MARIADB=10.4
VERSION_REDIS=6.4

SUFFIX_MARIADB="10_4"
SUFFIX_REDIS="6_4"

#Option Tools
OPTION_ALL=all
OPTION_DEFAULT=default
OPTION_NGINX=nginx
OPTION_MARIADB=mariadb
OPTION_REDIS=redis

#Action
ACTION_INSTALL=install
ACTION_LARAVEL=laravel

dockerBuild() {
  echo "[Building]"
  docker compose up -d --build
}

runNginx() {
  echo "[$OPTION_NGINX setup]"
  DIRECTORY=$WORK_DIR/tools/$OPTION_NGINX 
  cd $DIRECTORY
  dockerBuild
}

runMariadb() {
  echo "[$OPTION_MARIADB setup]"
  DIRECTORY=$WORK_DIR/tools/$OPTION_MARIADB 
  cd $DIRECTORY
  DOCKER_COMPOSE=$DIRECTORY/docker-compose.yml
  DOCKER_COMPOSE_SETUP=$DIRECTORY/docker-compose.setup
  cp $DOCKER_COMPOSE_SETUP $DOCKER_COMPOSE
  sed -i "s/<version>/$VERSION_MARIADB/g" $DOCKER_COMPOSE
  sed -i "s/<suffix>/$SUFFIX_MARIADB/g" $DOCKER_COMPOSE
  dockerBuild
}

runRedis() {
  echo "[$OPTION_REDIS setup]"
  DIRECTORY=$WORK_DIR/tools/$OPTION_REDIS
  cd $DIRECTORY
  DOCKER_COMPOSE=$DIRECTORY/docker-compose.yml
  DOCKER_COMPOSE_SETUP=$DIRECTORY/docker-compose.setup
  cp $DOCKER_COMPOSE_SETUP $DOCKER_COMPOSE
  sed -i "s/<version>/$VERSION_REDIS/g" $DOCKER_COMPOSE
  sed -i "s/<suffix>/$SUFFIX_REDIS/g" $DOCKER_COMPOSE
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
      # If it already exists, display a message
      echo "Directory '$1' already exists."
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

}

createLaravel() {
  php -v || echo "php not found"
  composer -V || echo "composer not found"
  echo $REPOSITORIES_DIR
  cd $REPOSITORIES_DIR
  REPOSITORY_DIR="$REPOSITORIES_DIR/$1"
  createRepositoryDir $REPOSITORY_DIR
  cd $REPOSITORY_DIR
  cp $DOCKER_TEMPLATES_DIR/laravel/* ./
  cp $DOCKER_TEMPLATES_DIR/laravel/.dockerignore ./.dockerignore
  composer create-project laravel/laravel src

  PROJECT_DIR=$REPOSITORY_DIR/$1
  cp $REPOSITORIES_DIR/config/template.code-workspace "$1.code-workspace"
}


# Main function
main() {
  mainAction
}

main
