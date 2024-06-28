#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/leoDict.sh"
source "$DIR/oxfordDict.sh"
source "$DIR/settings-funct.sh"


function ask()
{
  STEM=$1
  echo -e "\e[1;32;1;40;2m$STEM\e[0m"
  quoteBook $STEM
  OPS=( 'next' 'ask leo' 'ask oxford' )
  if [ "$device" == "kindle" ]; then
    OPS+=( 'archive' )
  fi
  select OPERATION in "${OPS[@]}"; do
      case $OPERATION in 
        "ask leo")
            echo "asking leo for meaning of: ${STEM}"
            search ${STEM} ${dictLang}
            ;;
        "ask oxford")
            echo "asking oxford for meaning of: $STEM"
            oxford ${STEM}
            ;;
        "archive")
            archive $STEM
            break ;;
        "next")
            break ;;
        *)
            #rephrase the quest
            echo -e "\e[1;32;1;40;2m$STEM\e[0m"
            quoteBook $STEM 
            ;;
      esac
  done
}

function installDeps()
{
  if ! [ -x "$(command -v sqlite3)" ]; then
    sudo apt install -y sqlite3
  fi
}

function main()
{
  initSettings
  installDeps

  if [ "$device" == "kindle" ]; then
    . kindleVoc.sh "${db}"
    echo "Which words do you want to train?"
    MODE=$(askMode)
  else
    . kobo/koboVoc.sh "${db}" "${kMount}"
    MODE="${dictLang}"
  fi
  
  WORD_RAW=$(selectWords $MODE) 
  read -r -a WORDS <<< "$WORD_RAW"

  COUNT=${#WORDS[@]}
  echo "started training of ${COUNT} words"
  for WORD in ${WORDS[@]}; do
    ask $WORD
  done
}

main
