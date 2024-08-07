#!/bin/bash

if ! [ -x "$(command -v leo)" ]; then
  sudo apt install -y libwww-dict-leo-org-perl
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LEODB="$DIR/leoCache.db"

if ! [ -f "$LEODB" ]; then
  CREATE_TABLE="CREATE TABLE QUERY_CACHE ( word TEXT NOT NULL, response TEXT )"
  sqlite3 "$LEODB" "$CREATE_TABLE" 
fi

function search()
{
  WORD=$1; 
  BOOKLANG="en";
  if [ ! -z "$2" ]; then
    BOOKLANG="${2}"
  fi
  CACHE_QUERY="SELECT response FROM query_cache c WHERE c.word=='${WORD}'"
  RESPONSE=$(sqlite3 "$LEODB" "$CACHE_QUERY")
  if [[ $RESPONSE != *"matches for"* ]]; then
      #WORD_ENCODED=$(urlEncode "$WORD")
      RESPONSE=$(leo -l ${BOOKLANG}2de -n "${WORD}" | sed -e 's|[\”\“]|\"|g' | iconv -f ISO-8859-1 -t utf-8 )
      if [[ $RESPONSE == *"matches for"* ]]; then
          WRITE_QUERY="INSERT INTO QUERY_CACHE (word,response) VALUES ('${WORD}',\"${RESPONSE}\");"
          sqlite3 "$LEODB" "$WRITE_QUERY"
      fi
  fi
  
  echo "${RESPONSE}"
}

function urlEncode()
{
  WORD=$1;
  python3 -c 'import urllib.parse, sys; print(urllib.parse.quote_plus(sys.argv[1]))' "${WORD}"
}

function cleanSearch()
{ # reduce output: only actual translation lines
  search ${1} ${2} | \
    sed -e 's|.*dict\.leo\.org:||g' | \
    sed -e 's|^    .*||' | \
    sed -E 's|^ (.*)| \1|g' | \
    grep -Eo --null ' .*'
}

function resultSelect()
{
  word="$1"
  trans=$(( cleanSearch $1 ) 2>&1) 
  readarray -t lines <<< "$trans"  # linewise to array

  checks=( )
  for line in "${lines[@]}"; do
    checks+=("${line:1} " 0) # add state flag
  done

  # old school dialog:
  lineCount=${#lines[@]}
  let "height=8+$lineCount"
  width=80
  selected=$(whiptail --title "Best translation?" --backtitle "by leo.org" --noitem \
   --checklist "results for: $word" $height $width $lineCount "${checks[@]}" 3>&1 1>&2 2>&3)
  echo $selected
}
