#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/leoDict.sh"
source "$DIR/oxfordDict.sh"

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
  if [ "$device" == "kindle" ]; then
    ankiQuoteKindle $1
  else
    ankiQuoteKobo $1
  fi
}

function ankiQuoteKobo()
{
  word=$1
  book=$(bookOfWord $word)
  usage=$(findUsage "$book" "$word")
  ref=$(bookDesc "$book")

  HTML=$(highlight "$usage" "$word" "<b>" "</b>")
  HTML+="<br/><i class=\"ref\">$ref</i><br/>"
  echo "$HTML"
}

function ankiQuoteKindle()
{
  WORD="$1"
  QUOTED=$(quoteBook "${WORD}" "<b>" "</b>")

  HTML=""
  readarray -t QLINES <<< "$QUOTED"
  for QUOTE in "${QLINES[@]}"; do
    IFS='|'; read -r -a PARTS <<< "${QUOTE}"
    HTML+="${PARTS[0]:0:-1}<br/>"
    HTML+="<i class=\"ref\">${PARTS[1]:1:-1} (${PARTS[2]:1:-1})</i><br/>"
  done
  echo "$HTML"
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

function initSettings()
{
  settings="$DIR/settings.conf"
  if ! [ -f "$settings" ]; then
    echo "No settings found at '$settings' using '$(basename ${settings}.template)'"
    echo "Setup your actual environment by copying the template to '$(basename $settings)' and adjust it to your preferences."
    settings="${settings}.template"
  fi
  . "$settings"
}

function anki()
{
  initSettings

  if [ "$device" == "kindle" ]; then
    . kindleVoc.sh "${db}"
    echo "Which words do you want to select?"
    MODE=$(askMode)
  else
    . kobo/koboVoc.sh "${db}" "${kMount}"
  fi


  WORD_RAW=$(selectWords $MODE) 
  read -r -a WORDS <<< "$WORD_RAW"

  SEP='|'
  FILE='anki.txt'
  rm "$FILE"
  for WORD in ${WORDS[@]}; do
    toAnkiLine "${WORD}" "${SEP}" >> $FILE
  done

  cat $FILE
}

if ! [ "$1" == "test" ]; then
  anki
fi
