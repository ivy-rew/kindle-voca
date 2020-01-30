#!/bin/bash

source kindleVoc.sh "sample/vocab.db"
source leoDict.sh
source oxfordDict.sh

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

function htmlBreak()
{
  input=$1
  html=()
  readarray -t lines <<< "${input}"
  for line in "${lines[@]}"; do
    html+=("${line}</br>")
  done
  echo "${html[*]}"
}

function toAnkiLine()
{
  WORD=$1
  SEP=$2

  QUOTED=$(quoteBook ${WORD})
  QUOUT=$(htmlBreak "${QUOTED}")

  OXFORD=$(oxford ${WORD})
  OXOUT=$(htmlBreak "${OXFORD}")

  LEO=$(cleanSearch ${WORD})
  LEOUT=$(htmlBreak "${LEO}")

  LINE="${WORD}${SEP}${QUOUT}${SEP}${OXOUT}${SEP}${LEOUT}"
  echo "$LINE"
}

function anki()
{
  echo "Which words do you want to select?"
  MODE=$(askMode)
  WORD_RAW=$(selectWords $MODE) 
  read -r -a WORDS <<< "$WORD_RAW"

  SEP='$'
  FILE='anki.txt'
  rm "$FILE"
  for WORD in ${WORDS[@]}; do
    toAnkiLine "${WORD}" "${SEP}" >> $FILE
  done

  cat $FILE
}

anki
