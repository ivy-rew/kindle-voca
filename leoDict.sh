#!/bin/bash

if ! [ -x "$(command -v leo)" ]; then
  sudo apt install -y libwww-dict-leo-org-perl
fi

LEODB="leoCache.db"

if ! [ -f "$LEODB" ]; then
  CREATE_TABLE="CREATE TABLE QUERY_CACHE ( word TEXT NOT NULL, response TEXT )"
  sqlite3 $LEODB "$CREATE_TABLE" 
fi

function search()
{
  WORD=$1
  CACHE_QUERY="SELECT response FROM query_cache c WHERE c.word=='${WORD}'"
  RESPONSE=$(sqlite3 $LEODB "$CACHE_QUERY")
  if [[ $RESPONSE != *"matches for"* ]]; then
      RESPONSE=$(leo ${WORD})
      if [[ $RESPONSE == *"matches for"* ]]; then
          WRITE_QUERY="INSERT INTO QUERY_CACHE (word,response) VALUES ('${WORD}',\"${RESPONSE}\");"
          sqlite3 $LEODB "$WRITE_QUERY"
      fi
  fi
  echo -e "$RESPONSE"
}

function cleanSearch()
{
  search ${1} | \
    sed -e 's|.*dict\.leo\.org:||g' | \
    sed -e 's|^    .*||' | \
    sed -E 's|^ (.*)| \1|g' | \
    grep -Eo --null ' .*'
}

function resultSelect()
{
  trans=$(( cleanSearch $1 ) 2>&1) 
  readarray -t lines <<< "$trans"
  select line in "${lines[@]}"; do
    echo "$line"
  done
}
