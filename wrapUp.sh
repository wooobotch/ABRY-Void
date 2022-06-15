#!/bin/bash

set -Eeo pipefail

echo -e $"*****************************************\n
*** Auto-Bootstrapper & Resource Yoke ***\n
***        Void Linux Edition         ***\n
***        Guided Installation        ***\n
*****************************************\n"

#Checks for the right distro and version before starting the process
#WIP
check_linux (){
  echo -e "\aChecking for distro and version:"
  OS_ID=$(. /etc/os-release && echo "$ID")
  OS_VER=$(. /etc/os-release && echo "$VERSION_ID")

  if [ $OS_ID = ubuntu ]; then
    if [ \( "$OS_VER"=="20.04" \) ]; then
      echo "The OS matches the requierements." && sleep 1s
    else
      echo $"Newer version of the operating system is needed."
#      exit 1
    fi
  else
    sleep 1s
    echo "Wrong distro, try Ubuntu 20.04"
#    exit 1
  fi
}

#Puts dotfiles and other configuration files in their corresponding directories
#WIP
#Check targeted folders
dotfiles_mover () {
  echo -e "\aMoving configuration files..." && sleep 1s
  cp -r  $1/dotfiles/. $1/..
}

#Downloads suckless stuff from repo
get_unsucked () {
  echo -e "\aGetting repos..." && sleep 1s
  [ -d "$1/../abry/repos" ] || mkdir -p $1/../abry/repos
  cp repo-list $1/../abry/repos
  cd $1/../abry/repos
  for URL in $(xargs echo < repo-list); do
    REPO=$(echo $URL | rev | cut -d "/" -f 1 | rev)
    [ ! -d "$REPO" ] && git clone $URL
  done
  rm repo-list
  cd -
  echo "The repos listed were downloaded!!" && sleep 1s
}

#Calls make and make clean install
maker () {
  echo -e "\aMaking $1!" && sleep 1s
  cd $1
  make || echo "Couldn't 'make'"
  sudo make clean install || echo "$1 installtion aborted"
  cd -
}

#General installation function
#WIP
installation () {
  echo -e "\aPackage and repositories installation:" && sleep 1s
  cd $1
  sudo xbps-install -u xbps
  sudo xbps-install -S
#  xargs sudo apt-get install -y --no-install-recommends < add-list
  xargs sudo xbps-install -y < add-list
  cd $1/../abry/repos
  for DIREC in $(xargs echo < repo-list); do
    [ -d "$(basename "$DIREC")" ] && maker "$(basename "$DIREC")"
  done
  cd -
}

#Uninstalation and obsolete package removal
#WIP
clean_up (){
  echo -e "\aRevoming unnecesary reminders..." && sleep 1s
  cd $1
#  xargs sudo apt-get remove < remove-list
#  xargs sudo xbps-remove < remove-list
#  sudo apt-get autoremove
#  sudo xbps-remove
}

#Main function, it calls everything else
main () {
  check_linux
  get_unsucked $1
  dotfiles_mover
  installation $1
  clean_up $1

  echo -e "Call \`sudo shutdown -r now\` to complete the setup.\n"
}

#Here starts it all
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
main $SCRIPTPATH
