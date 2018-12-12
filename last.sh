#!/bin/bash

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[1;32m'
COLOR_ORANGE='\033[0;33m'
COLOR_YELLOW='\033[1;33m'
COLOR_PURPLE='\033[1;35m'
COLOR_CYAN='\033[1;36m'
COLOR_NONE='\033[0m'

usage () {
	printf "\n\t ${COLOR_GREEN}"
	printf "\n\t██╗     ███████╗███████╗████████╗███████╗██╗   ██╗"
	printf "\n\t██║     ██╔══██║██╔════╝ ╚═██╔══╝██╔════╝██║   ██║"
	printf "\n\t██║     ███████║███████╗   ██║   ███████╗████████║"
	printf "\n\t██║     ██╔══██║╚════██║   ██║   ╚════██║██╔═══██║"
	printf "\n\t███████╗██║  ██║███████║   ██║${COLOR_CYAN}██╗${COLOR_GREEN}███████║██║   ██║"
	printf "\n\t╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝${COLOR_CYAN}╚═╝${COLOR_GREEN}╚══════╝╚═╝   ╚═╝"
	printf "\n${COLOR_NONE}"
	printf "\n\t Usage: last.sh [args]"
	printf "\n\t\t -r\t\tRun"
	printf "\n\t\t -h\t\tHelp"
	printf "\n\t\t -c\t\tCredentials setup."
	printf "\n\t\t -d\t\tDelete credentials."
	printf "\n\t\t -a\t\tRelay API information. Returns formatted reply in cleartext."
	printf "\n\t\t -q\t\tRelay API information. Returns json."
	printf "\n\t\t -p\t\tPolybar mode, returns output once."
	printf "\n\n${COLOR_NONE}"
}

run () {
	credentials
	runner
}

polybar () {
	source /etc/environment
	if [[ $LASTFM_USER == "" ]] || [[ $LASTFM_API_KEY == "" ]]; then
		exit 1
	fi

	response=`curl -s "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=$LASTFM_USER&api_key=$LASTFM_API_KEY&format=json"`
	artist=`echo "$response" | jq ".[] | .track | .[0] | .artist " | tr -d "\#" | jq ".text" | tr -d '"'`
	track=`echo "$response" | jq ".[] | .track | .[0] | .name" | tr -d '"'`
	album=`echo "$response" | jq ".[] | .track | .[0] | .album " | tr -d "\#" | jq ".text" | tr -d '"'`
	curr="$track - $artist"

	isPlaying=`echo "$response" | jq '.[] | .track | .[0] | .["@attr"] | .nowplaying' | tr -d '"'`
	if [[ $isPlaying == true ]]; then
		echo "$curr"
	fi
}

ctapi () {
	source /etc/environment
	if [[ $LASTFM_USER == "" ]] || [[ $LASTFM_API_KEY == "" ]]; then
		exit 1
	fi

	response=`curl -s "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=$LASTFM_USER&api_key=$LASTFM_API_KEY&format=json"`
	if [[ "${OPTARG}" == "track" ]]; then
		track=`echo "$response" | jq ".[] | .track | .[0] | .name" | tr -d '"'`
		printf "$track"
		exit 0
	elif [[ "${OPTARG}" == "artist" ]]; then
		artist=`echo "$response" | jq ".[] | .track | .[0] | .artist" | tr -d "\#" | jq ".text" | tr -d '"'`
		printf "$artist"
		exit 0
	elif [[ "${OPTARG}" == "album" ]]; then
		album=`echo "$response" | jq ".[] | .track | .[0] | .album" | tr -d "\#" | jq ".text" | tr -d '"'`
		printf "$album"
		exit 0
	elif [[ "${OPTARG}" == "url" ]]; then
		url=`echo "$response" | jq ".[] | .track | .[0] | .url" | tr -d '"'`
		printf "$url"
		exit 0
	fi
}

jqapi () {
	source /etc/environment
	if [[ $LASTFM_USER == "" ]] || [[ $LASTFM_API_KEY == "" ]]; then
		exit 1
	fi

	response=`curl -s "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=$LASTFM_USER&api_key=$LASTFM_API_KEY&format=json"`

	if [[ "${OPTARG}" == "pure" ]]; then
		printf "$response"
		exit 0
	elif [[ "${OPTARG}" == "track" ]]; then
		track=`echo "$response" | jq ".[] | .track | .[0]" | tr -d '"'`
		printf "$track"
		exit 0
	fi
}

animate () {
	chars="/-\|"

	for (( i=0; i<${#chars}; i++ )); do
		sleep 0.1
	  echo -en "${chars:$i:1}" "\r"
  done
}

credentials () {
	source /etc/environment
	if [[ $LASTFM_USER == "" ]] || [[ $LASTFM_API_KEY == "" ]]; then
		getCredentials
	fi
}

getCredentials () {
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
	source /etc/environment
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
	sudo sed -i 's/.*LASTFM_USER.*//g' /etc/environment
	sudo sed -i 's/.*LASTFM_API_KEY.*//g' /etc/environment
	sed -i '/^$/d' /etc/environment
	printf "${COLOR_ORANGE}Credentials deleted!${COLOR_NONE}"
}

runner () {
	source /etc/environment

	prev=""
	while true; do
		animate
		response=`curl -s "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=$LASTFM_USER&api_key=$LASTFM_API_KEY&format=json"`
		artist=`echo "$response" | jq ".[] | .track | .[0] | .artist " | tr -d "\#" | jq ".text" | tr -d '"'`
		track=`echo "$response" | jq ".[] | .track | .[0] | .name" | tr -d '"'`
		album=`echo "$response" | jq ".[] | .track | .[0] | .album " | tr -d "\#" | jq ".text" | tr -d '"'`
		curr="--> $artist : $track ( $album )"

		isPlaying=`echo "$response" | jq '.[] | .track | .[0] | .["@attr"] | .nowplaying' | tr -d '"'`
		if [[ $isPlaying != true ]]; then
			echo -en "\033[2K"
			prev="$curr"
		elif [[ $isPlaying == true ]]; then
			echo -en "\033[2K"
			if (( ${#curr} > `tput cols` )); then
				curr="--> $artist : $track"
				if (( ${#curr} > `tput cols` )); then
					curr="--> $track"
					if (( ${#curr} > `tput cols` )); then
						curr="--> Error: README.rst"
					fi
				fi
			fi
			echo -en "$curr\r"
			prev="$curr"
		fi
		animate
		sleep 0.1;
	done
}

while getopts "rdchpa:q: " arg; do
	case "${arg}" in
		r) run;;
		d) deleteCredentials;;
		c) getCredentials;;
		p) polybar;;
		a) ctapi;;
		q) jqapi;;
		h|*) usage;;
	esac
done
