#!/bin/bash

source kindleVoc.sh "sample/vocab.db"
source leoDict.sh
source oxfordDict.sh

function ask()
{
  STEM=$1
  echo -e "\e[1;32;1;40;2m$STEM\e[0m"
  quoteBook $STEM
  select OPERATION in 'next' 'archive' 'ask leo' 'ask oxford'
    do
      case $OPERATION in 
        "ask leo")
            echo "asking leo for meaning of: ${STEM}"
            search ${STEM}
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

function askMode()
{
  RESULT="=0"
  select MODE in 'archived' 'open' 'all'
  do
    if [ "$MODE" == "archived" ]; then
        RESULT='=100'
    fi
    if [ "$MODE" == "open" ]; then
        RESULT='=0'
    fi
    if [ "$MODE" == "all" ]; then
        RESULT='>=0'
    fi
    break;
  done
  echo $RESULT
}

function installDeps()
{
  if ! [ -x "$(command -v sqlite3)" ]; then
    sudo apt install -y sqlite3
  fi
}

function main()
{
  installDeps

  echo "Which words do you want to train?"
  MODE=$(askMode)
  WORD_RAW=$(selectWords $MODE) 
  read -r -a WORDS <<< "$WORD_RAW"

  COUNT=${#WORDS[@]}
  echo "started training of ${COUNT} words"
  for WORD in ${WORDS[@]}; do
    ask $WORD
  done
}

main
