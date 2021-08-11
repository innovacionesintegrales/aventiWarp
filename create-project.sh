#!/bin/bash

OS_WSL="wsl"
OS_UBUNTU="ubuntu"
OS_DEBIAN="debian"
OS_MAC="mac"
INSTALLER_NAME="AventiWarp"

# Check availability of docker
hash docker 2>/dev/null || { echo >&2 "${INSTALLER_NAME} framework requires \"docker\""; exit 1; }

# Check availability of docker-compose
hash docker-compose 2>/dev/null || { echo >&2 "${INSTALLER_NAME} framework requires \"docker-compose\""; exit 1; }

#ColorsCreation
P_RED="\e[38;5;1m"
P_BLUE="\e[38;5;75m"
P_WHITE="\e[38;5;255m"

echo -e "$P_BLUE  __   ___    ____    __  ___   __   _   ____    __  ___   __    __   ____" 
echo "  ___ ____    ___    ____    __  ___    ____  __      ______    /  |\____ " 
echo " ____    ___________  ___ _________     ________________       /  /|/_    " 
echo "     _  /  __   /  / /  /  _____/  \   /  /___   ___/  / ___  /    \  ___ "
echo " ___   /  /_/  /  / /  /  /__  /    \ /  /   /  /  /  /      /___/  >_    " 
echo "      /  __   /  / /  /  ___/ /  /\  v  /   /  /  /  / ___ _    |  /____  " 
echo " ___ /  / /  /\  |/  /  /____/  /  \   /   /  /  /  / _    ____ |  |  _   " 
echo " _  /__/ /__/  \____/ \_____/__/    \_/   /__/  /__/  ___    __ | /  ___  " 
echo "  __   ___    ____    __  ___   __   _   ____    __  ___   __   |/_   ____"  
echo "  ___ ____    ___    ____    __  ___    ____  __      ______    ____    ___" 
echo "  ___ ____                                                    _    ____    __" 
echo -e "   ____ _   $P_WHITE $INSTALLER_NAME Docker-Magento Configuration System $P_BLUE __  ___    __"
echo -e "  __   ___    ____    __  ___   __   _   ____    __  ___   __    __   ____$P_WHITE" 
echo " " 
## Ask for Project Name
while : 
do
  read -p "Project Name: " PROJECT_NAME
  if [ ! $PROJECT_NAME = '' ] ; then
    break
  else 
    echo -e "$P_RED Please, Provide a valid project name $P_WHITE"
  fi
done
## Ask for Domain
while : 
do
  read -e -i local.${PROJECT_NAME}.com -p "Domain to use: " BASE_URL
  if [ ! $BASE_URL = '' ] ; then
    break
  else 
    echo -e "$P_RED Please, Provide a valid domain $P_WHITE"
  fi
done
## Ask for Magento Version
while : 
do
  read -p "Project version [ex 2.3.5-p2]: " VERSION
  if [ ! $VERSION = '' ] ; then
    break
  else 
    echo -e "$P_RED Please, Provide a valid version $P_WHITE"
  fi
done
while : 
do
  read -p "Gitlab repository url [ex: http://git.allers.com.co:2940/eMage/$PROJECT_NAME.git]: " GIT_REPO
  if [ ! $GIT_REPO = '' ] ; then
    break
  else 
    echo -e "$P_RED Please, Provide a valid git repository $P_WHITE"
  fi
done
while : 
do
  read -e -i magento_${PROJECT_NAME} -p "Database Name: " MYSQL_DATABASE
  if [ ! $MYSQL_DATABASE = '' ] ; then
    break
  else 
    echo -e "$P_RED Please, Provide a valid database name $P_WHITE"
  fi
done
while : 
do
  read -e -i magento -p "Database User: " MYSQL_USER
  if [ ! $MYSQL_USER = '' ] ; then
    break
  else 
    echo -e "$P_RED Please, Provide a valid database user $P_WHITE"
  fi
done
while : 
do
  read -e -i magento -p "Database Password: " MYSQL_PASSWORD
  if [ ! $MYSQL_PASSWORD = '' ] ; then
    break
  else 
    echo -e "$P_RED Please, Provide a valid database password $P_WHITE"
  fi
done
while : 
do
  read -e -i magento_${PROJECT_NAME}.sql -p "Database File: " RUTA_BD
  if [ ! $RUTA_BD = '' ] ; then
    break
  else 
    echo -e "$P_RED Please, Provide a database filename $P_WHITE"
  fi
done

echo "Detecting OS..."
echo "OS_WSL=${OS_WSL}" > ./conf/project.conf
echo "OS_UBUNTU=${OS_UBUNTU}" >> ./conf/project.conf
echo "OS_DEBIAN=${OS_DEBIAN}" >> ./conf/project.conf
echo "OS_MAC=${OS_MAC}">> ./conf/project.conf

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
  if [[ ${DISTRO} == *"Ubuntu"* ]]; then
    if uname -a | grep -q '^Linux.*icrosoft' ; then
      echo "OS=${OS_WSL}" >> ./conf/project.conf
    else
      echo "OS=${OS_UBUNTU}" >> ./conf/project.conf
    fi
  elif [[ ${DISTRO} == *"Debian"* ]]; then
      echo "OS=${OS_DEBIAN}" >> ./conf/project.conf
  else
      echo "Error: OS not detected"
      read -p "Press any key to continue ..."
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
      echo "OS=${OS_MAC}" >> ./conf/project.conf
fi

echo "Saving project configuration..."
echo "PROJECT_NAME=${PROJECT_NAME}" >> ./conf/project.conf
echo "BASE_URL=${BASE_URL}" >> ./conf/project.conf
echo "VERSION=${VERSION}" >> ./conf/project.conf
echo "GIT_REPOSITORY=${GIT_REPO}" >> ./conf/project.conf
echo "######### MSQL CONFIGURATION #########" >> ./conf/project.conf
echo "MYSQL_ROOT_PASSWORD"=root >> ./conf/project.conf
echo "MYSQL_DATABASE"=${MYSQL_DATABASE} >> ./conf/project.conf
echo "MYSQL_USER"=${MYSQL_USER} >> ./conf/project.conf
echo "MYSQL_PASSWORD"=${MYSQL_PASSWORD} >> ./conf/project.conf
echo "######### DOCKER CONFIGURATION #########" >> ./conf/project.conf
echo "DOCKER_SERVICE_APP"=app_${PROJECT_NAME}_m2 >> ./conf/project.conf
echo "DOCKER_SERVICE_PHP"=phpfpm_${PROJECT_NAME}_m2 >> ./conf/project.conf
echo "DOCKER_SERVICE_DB"=db_${PROJECT_NAME}_m2 >> ./conf/project.conf
echo "DOCKER_SERVICE_MAILHOG"=mailhog_${PROJECT_NAME}_m2 >> ./conf/project.conf
echo "######### PATHS CONFIGURATION #########" >> ./conf/project.conf
CURRENT_PATH="$(cd "$(dirname "$0")" && pwd)"
echo "PROJECT_PATH"=${CURRENT_PATH} >> ./conf/project.conf
echo "BIN_PATH"=${CURRENT_PATH}/bin >> ./conf/project.conf
echo "SRC_PATH"=${CURRENT_PATH}/src >> ./conf/project.conf
echo "CONF_PATH"=${CURRENT_PATH}/conf >> ./conf/project.conf

source ./conf/project.conf

## UPDATE /etc/hosts
echo "Adding ${BASE_URL} entry to /etc/hosts..."
echo "127.0.0.1 ${BASE_URL}" | sudo tee -a /etc/hosts

## Cono el repositorio 
echo "Cloning ${GIT_REPO}"
git clone ${GIT_REPO} src/


echo "Configuring docker-compose project file..."
cp ./conf/base.docker-compose.yml ./docker-compose.yml
sed -i "s/PROJECTNAME/${PROJECT_NAME}/g" ${PROJECT_PATH}/docker-compose.yml

echo "Starting docker services..."
sudo docker-compose up -d
sleep 10 #Ensure containers are loaded

echo "Loading Magento and environment configuration..."
source conf/setup_magento_config
#source conf/env/db.env

echo "Installing Magento..."
bin/clinotty bin/magento setup:install \
  --db-host=${DOCKER_SERVICE_DB} \
  --db-name=${MYSQL_DATABASE}\
  --db-user=${MYSQL_USER} \
  --db-password=${MYSQL_PASSWORD} \
  --base-url=https://${BASE_URL}/ \
  --admin-firstname=${ADMIN_FIRST_NAME} \
  --admin-lastname=${ADMIN_LAST_NAME} \
  --admin-email=${ADMIN_EMAIL} \
  --admin-user=${ADMIN_USER} \
  --admin-password=${ADMIN_PASSWORD} \
  --backend-frontname=${ADMIN_URL} \
  --language=${LANGUAGE} \
  --currency=${CURRENCY} \
  --use-rewrites=1 \
  --use-secure=1 \
  --use-secure-admin=1 \
  --timezone=America/Bogota


## SETEO LA BD
echo "Seteando la base de datos ${RUTA_BD}"
bin/databaseimport bd/${RUTA_BD} 

echo "Copying files from container to host after install..."
#mkdir src
bin/copyfromcontainer --all

echo "Generating SSL certificate..."
bin/setup-ssl ${BASE_URL}

echo "Configuring post install docker-compose file..."
docker-compose stop
sed -i "s/#      - \.\/src:/      - \.\/src:/g" ./docker-compose.yml
sed -i "s/#      - \.\/conf/      - \.\/conf/g" ./docker-compose.yml
sed -i "s/      - appdata/#      - appdata/g" ./docker-compose.yml

${BIN_PATH}/start
sleep 10 #Ensure containers are loaded

#Removing unneed mounted files
cp ${SRC_PATH}/nginx.conf.sample ${SRC_PATH}/nginx.conf
if test -f ${PROJECT_PATH}/docker-compose.yml\'\'
then
  rm -f ${PROJECT_PATH}/docker-compose.yml\'\'
fi

${BIN_PATH}/restart
echo "Docker development environment setup complete."
sleep 10 #Ensure containers are loaded


while : 
do
  read -p "Please, make sure if you have conf.php AND env.php On your "app/etc/" Magento environment (The default Mysql Host Connection is db_${PROJECT_NAME}_m2)[yes]: " FLAG
  if [ ! $FLAG = '' ] ; then
    break
  else 
    echo -e "$P_RED Please, make sure $P_WHITE"
  fi
done

## CORRIJO PERMISOS
echo "Corrigiendo Permisos para el entorno"
bin/fixperms
## CORIJO OWNERS
echo "Corrigiendo owners para el entorno"
bin/fixowns 

echo "Installing composer"
sudo bin/composer install

## Configuro las urls
sudo bin/magento setup:store-config:set --base-url="http://${BASE_URL}/"
sudo bin/magento setup:store-config:set --base-url-secure="https://${BASE_URL}/"

echo "Turning on developer mode.."
sudo bin/magento deploy:mode:set developer


echo "Cleaning directories.."
sudo rm -rf var/* generated/* pub/static/* 

echo "Setup upgrade.."
sudo bin/magento setup:upgrade

echo "deploying content.."
sudo bin/magento setup:static-content:deploy es_CO en_US -f

echo "Reindexing.."
sudo bin/magento indexer:reindex

echo "Compile.."
sudo bin/magento setup:di:compile

echo "Clearing the cache to apply updates..."
sudo bin/magento cache:flush

echo "You may now access your Magento instance at https://${BASE_URL}/"
echo "Backend information:"
echo "- url: https://${BASE_URL}/"
echo "- url: https://${BASE_URL}/${ADMIN_URL}"



