#!/bin/bash
WORK_DIR=$PWD
NGINX_DIR=$PWD/../../tools/nginx 

createProjectApache() {
  SERVER_NAME=$1
  cd $NGINX_DIR/conf.d
  cp website.conf.template $SERVER_NAME.conf
  sed -i "s/<server_name>/$SERVER_NAME/g" $SERVER_NAME.conf
  addToHost $SERVER_NAME
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

main() {
  createProjectApache $1
}

main $1