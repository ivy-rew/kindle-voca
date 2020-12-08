#!/bin/bash

DB=$1

function quoteBook()
{
  STEM=$1
  BOOK_QUERY="SELECT replace(l.usage,\"
\",\" \"), b.title, b.authors, w.word 
    FROM WORDS w
    JOIN BOOK_INFO b ON b.id = l.book_key
    JOIN LOOKUPS l on w.id = l.word_key
    WHERE w.stem == '${STEM}'"
  RESR=$(sqlite3 -separator ' | ' $DB "$BOOK_QUERY")
  readarray -t RES <<< ${RESR}
  
  start=$(tput setaf 1)
  if [ ! -z "$2" ]; then
    start="${2}"
  fi
  end=$(tput sgr0)
  if [ ! -z "$3" ]; then
    end="${3}"
  fi
  
  for Q in "${RES[@]}"; do
    WORD=$(echo "${Q}" | awk -F "| " '{print $NF}')
    WLEN=${#WORD}
    CUT=$(($WLEN+2))
    QUOTE="${Q:0:-${CUT}}"
    echo "${QUOTE}" | sed -e "s|$WORD|${start}${WORD}${end}|g"
  done
}

function archive()
{
  WORD=$1
  ARCHIVE_SQL="UPDATE WORDS 
      SET category=100 
      WHERE stem='$WORD';"
  sqlite3 $DB "$ARCHIVE_SQL"
}

function selectWords()
{
  CATEGORY=$1
  WORDLIST_QUERY="SELECT DISTINCT stem 
    FROM words
    WHERE category$CATEGORY
    ORDER BY timestamp DESC"
  WORDS=$(sqlite3 -newline ' ' $DB "$WORDLIST_QUERY")
  echo $WORDS
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
