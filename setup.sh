#!/bin/bash
OPTION_ALL=all
OPTION_DEFAULT=default
OPTION_NGINX=nginx
OPTION_MARIADB=mariadb
OPTION_REDIS=redis
WORK_DIR=$PWD

VERSION_MARIADB=10.4
VERSION_REDIS=6.4

SUFFIX_MARIADB="10_4"
SUFFIX_REDIS="6_4"

dockerBuild() {
echo "[Building]"
#docker compose up -d --build
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

# Main function
main() {
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

main
