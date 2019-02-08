#!/bin/bash

C_RED='\033[0;31m'
C_GREEN='\033[1;32m'
C_ORANGE='\033[0;33m'
C_YELLOW='\033[1;33m'
C_PURPLE='\033[1;35m'
C_CYAN='\033[1;36m'
C_NONE='\033[0m'

usage () {
	printf "\n\t ${C_GREEN}"
	printf "\n\t██╗     ███████╗███████╗████████╗███████╗██╗   ██╗"
	printf "\n\t██║     ██╔══██║██╔════╝ ╚═██╔══╝██╔════╝██║   ██║"
	printf "\n\t██║     ███████║███████╗   ██║   ███████╗████████║"
	printf "\n\t██║     ██╔══██║╚════██║   ██║   ╚════██║██╔═══██║"
	printf "\n\t███████╗██║  ██║███████║   ██║${C_CYAN}██╗${C_GREEN}███████║██║   ██║"
	printf "\n\t╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝${C_CYAN}╚═╝${C_GREEN}╚══════╝╚═╝   ╚═╝"
	printf "\n${C_NONE}"
	printf "\n\t Usage: last.sh [args]"
	printf "\n\t\t -r\t\tRun"
	printf "\n\t\t -h\t\tHelp"
	printf "\n\t\t -c\t\tCredentials setup."
	printf "\n\t\t -d\t\tDelete credentials."
	printf "\n\t\t -p\t\tPolybar mode, returns output once."
	printf "\n\t\t -u\t\tDefine a custom user that is not saved as credentials."
	printf "\n\n${C_NONE}"
}

customUser () {
	credentials
	LASTFM_USER=${OPTARG}
	runner
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
	printf "${C_GREEN}"
	read -p "Username: " LASTFM_USER
	printf "${C_RED}"
	read -sp "API Key: " LASTFM_API_KEY

	printf "\n\n"
	read -p "Save credentials? [y/N] " choice
	case "$choice" in
		y|Y) saveCredentials;;
	esac

	printf "${C_CYAN}\nWelcome, $LASTFM_USER!\n${C_NONE}"
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
	printf "${C_GREEN}Credentials saved!${C_NONE}"
}

deleteCredentials () {
	sudo sed -i 's/.*LASTFM_USER.*//g' /etc/environment
	sudo sed -i 's/.*LASTFM_API_KEY.*//g' /etc/environment
	sed -i '/^$/d' /etc/environment
	printf "${C_ORANGE}Credentials deleted!${C_NONE}"
}

runner () {
	prev=""
	while true; do
		animate
		response=`curl -s "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=$LASTFM_USER&api_key=$LASTFM_API_KEY&format=json"`

		if echo "$response" | jq ".[] | .track | .[0] | .name" | tr -d '"'  > /dev/null; then
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
							curr="--> Error: README"
						fi
					fi
				fi
				echo -en "$curr\r"
				prev="$curr"
			fi
		else
			echo "track lookup failed"
		fi
		animate
		sleep 0.1;
	done
}

polybar () {
	source /etc/environment
	if [[ $LASTFM_USER == "" ]] || [[ $LASTFM_API_KEY == "" ]]; then
		exit 1
	fi

	response=`curl -s "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=$LASTFM_USER&api_key=$LASTFM_API_KEY&format=json"`

	if echo "$response" | jq ".[] | .track | .[0] | .name" | tr -d '"'  > /dev/null; then
		artist=`echo "$response" | jq ".[] | .track | .[0] | .artist " | tr -d "\#" | jq ".text" | tr -d '"'`
		track=`echo "$response" | jq ".[] | .track | .[0] | .name" | tr -d '"'`
		album=`echo "$response" | jq ".[] | .track | .[0] | .album " | tr -d "\#" | jq ".text" | tr -d '"'`
		curr="$track - $artist"

		isPlaying=`echo "$response" | jq '.[] | .track | .[0] | .["@attr"] | .nowplaying' | tr -d '"'`
		if [[ $isPlaying == true ]]; then
			echo "$curr"
		else
			echo ""
		fi
	else
		echo "track lookup failed"
	fi
}

while getopts "rdchpu:a:q: " arg; do
	case "${arg}" in
		r) credentials; runner;;
		d) deleteCredentials;;
		c) getCredentials;;
		p) polybar;;
		u) customUser;;
		h|*) usage;;
	esac
done
