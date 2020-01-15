#!/bin/bash

source kindleVoc.sh "sample/vocab.db"
source leoDict.sh
source oxfordDict.sh

function ask()
{
  WORD=$1
  echo -e "\e[1;32;1;40;2m$WORD\e[0m"
  quoteBook $WORD
  select OPERATION in 'next' 'archive' 'ask leo' 'ask oxford'
    do
        if [ "$OPERATION" == "ask leo" ]; then
            echo "asking leo for meaning of: $WORD"
            search ${WORD}
        fi
        if [ "$OPERATION" == "ask oxford" ]; then
            echo "asking oxford for meaning of: $WORD"
            oxford ${WORD}
        fi
        if [ "$OPERATION" == "archive" ]; then
            archive $WORD
            break;
        fi
        if [ "$OPERATION" == "next" ]; then
            break;
        fi
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
  WORDS=$(selectWords $MODE)

  for WORD in $WORDS; do
    ask $WORD
  done
}

main
