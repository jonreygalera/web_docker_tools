#!/bin/bash
OPTION_ALL=all
OPTION_DEFAULT=default
OPTION_NGINX=nginx
OPTION_MARIADB=mariadb
OPTION_REDIS=redis
WORK_DIR=$PWD

runNginx() {
    echo "---$OPTION_NGINX setup---"
    cd $WORK_DIR/tools/$OPTION_NGINX 
    docker compose up -d --build
}

runMariadb() {
    echo "---$OPTION_MARIADB setup---"
    cd $WORK_DIR/tools/$OPTION_MARIADB 
    docker compose up -d --build
}

runRedis() {
    echo "---$OPTION_REDIS setup---"
    cd $WORK_DIR/tools/$OPTION_REDIS 
    docker compose up -d --build
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
    #     break;
    done
    
}

main
