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

function ankiQuote()
{
  WORD="$1"
  QUOTED=$( quoteBook "${WORD}" )
  
  HTML=""
  readarray -t QLINES <<< "$QUOTED"
  for QUOTE in "${QLINES[@]}"; do
    IFS='|'; read -r -a PARTS <<< "${QUOTE}"
    HTML+="${PARTS[0]:0:-1}<br/>"
    HTML+="<i class=\"ref\">${PARTS[1]:1:-1} (${PARTS[2]:1})</i><br/>"
  done
  
  RESULT=$(echo "${HTML}" | \
    sed -e "s|${WORD}|<b>${WORD}</b>|g")
  echo "$RESULT"
}

function leoSplit()
{
  LINE="$1"
  TRANS=$(echo "$LINE" | \
   sed -E "s| (.*) ([ ]{3,})(.*)|<span class=\"word\">\1</span><span class=\"trans\">\3</span>|g")
  echo "$TRANS"
}

function ankiLeo()
{
  WORD="$1"
  LEO=$(cleanSearch "${WORD}")
  readarray -t TLINES <<< "${LEO}"
  HOUT=""
  for L in "${TLINES[@]}"; do
    HOUT+=$(leoSplit "${L}")
    HOUT+="\n"
  done
  printf "$HOUT"
}

function toAnkiLine()
{
  WORD=$1
  SEP=$2

  QUOTED=$(ankiQuote "${WORD}")
  QUOUT=$(htmlBreak "${QUOTED}")

  OXFORD=$(oxford "${WORD}")
  OXOUT=$(htmlBreak "${OXFORD}")

  LEO=$(ankiLeo "${WORD}")
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
