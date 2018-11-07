#!/bin/bash

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[1;32m'
COLOR_ORANGE='\033[0;33m'
COLOR_YELLOW='\033[1;33m'
COLOR_PURPLE='\033[1;35m'
COLOR_CYAN='\033[1;36m'
COLOR_NONE='\033[0m'

run () {
	printf "run\n"
	credentials
	runner
}

refresh () {
	printf "refresh\n"
	source /etc/environment
}

credentials () {
	printf "credentials\n"
	refresh
	if [[ $LASTFM_USER == "" ]] || [[ $LASTFM_API_KEY == "" ]]; then
		getCredentials
	fi
}

getCredentials () {
	printf "getCredentials\n"
	
	printf "${COLOR_GREEN}"
	read -p "Username: " LASTFM_USER
	printf "${COLOR_RED}"
	read -sp "API Key: " LASTFM_API_KEY

	printf "\n\n"
	read -p "Save credentials? [y/N] " choice
	case "$choice" in
		y|Y) saveCredentials;;
	esac

	printf "${COLOR_CYAN}\nWelcome, $LASTFM_USER!\n${COLOR_NONE}"
}

saveCredentials () {
	printf "saveCredentials\n"
	refresh
	if [[ $LASTFM_USER == "" ]]; then
		sudo echo -e "\nLASTFM_USER=\"$LASTFM_USER\"" >> /etc/environment
	else
		sudo sed -i 's/.*LASTFM_USER.*//g' /etc/environment
		sudo echo -e "\nLASTFM_USER=\"$LASTFM_USER\"" >> /etc/environment
	fi
	if [[ $LASTFM_API_KEY == "" ]]; then
		sudo echo -e "\nLASTFM_API_KEY=\"$LASTFM_API_KEY\"" >> /etc/environment
	else
		sudo sed -i 's/.*LASTFM_API_KEY.*//g' /etc/environment
		sudo echo -e "\nLASTFM_API_KEY=\"$LASTFM_API_KEY\"" >> /etc/environment
	fi
	sed -i '/^$/d' /etc/environment
	printf "${COLOR_GREEN}Credentials saved!${COLOR_NONE}"
}

deleteCredentials () {
	printf "deleteCredentials\n"
	sudo sed -i 's/.*LASTFM_USER.*//g' /etc/environment
	sudo sed -i 's/.*LASTFM_API_KEY.*//g' /etc/environment
	sed -i '/^$/d' /etc/environment
	printf "${COLOR_ORANGE}Credentials deleted!${COLOR_NONE}"
}

runner () {
	printf "runner\n"
	refresh

	prev=""
	while true; do
		response=`curl -s "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=$LASTFM_USER&api_key=$LASTFM_API_KEY&format=json"`
		echo "$response"
		exit 0
		#if [ $prev != $current ]; then
		#	printf "new"
		#fi
		#sleep 1
	done
}

while getopts "rdc" arg; do
	case "${arg}" in
		r) run;;
		d) deleteCredentials;;
		c) getCredentials;;
	esac
done
