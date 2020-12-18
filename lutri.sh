#!/bin/sh

source $HOME/.*profile
CACHE_DIR=${XDG_CACHE_HOME:-"$HOME/.cache"}
CACHE=$CACHE_DIR/lutrish-games.json

cols=$(tput cols)
lines=$(tput lines)

declare -i width && width=cols-20
declare -i height && height=lines-10

wc -c $CACHE |\
 grep $(lutris --list-games --installed --json |\
 awk '/\[/ { show=1 } show; /\]/ { show=0 }' |\	       
 jq '.[] | {name: .slug, runner: .runner}' | wc -c) ||\
 lutris --list-games --installed --json |\
 awk '/\[/ { show=1 } show; /\]/ { show=0 }' |\
 jq '.[] | {name: .slug, runner: .runner}' > $CACHE 

dialog_func = ${dialog_func=dialog}

game=`$dialog_func --stdout --backtitle "Lutrish" \
 --title "Games $$" \
 --menu "" \
 $height $width \
 $height $(cat $CACHE | jq '.[]' | tr -d '"')`

[[ -n $game ]] && nohup lutris lutris:rungame/$game > /dev/null &
sleep 1s # Without the delay, this for some reason doesn't do what I want it to.
kill $$
