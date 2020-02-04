#!/bin/bash

DB=$1

function quoteBook()
{
  STEM=$1
  BOOK_QUERY="SELECT l.usage, b.title, b.authors, w.word FROM LOOKUPS l
JOIN BOOK_INFO b ON b.id = l.book_key
JOIN WORDS w on w.id = l.word_key
WHERE w.stem == '$STEM'"
  RESR=$(sqlite3 -separator ' | ' $DB "$BOOK_QUERY")
  readarray -t RES <<< ${RESR}
  WORD=$(echo "${RES[0]}" | awk -F "| " '{print $NF}')
  WLEN=${#WORD}
  CUT=$(($WLEN+2))
  for Q in "${RES[@]}"; do
    QUOTE="${Q:0:-${CUT}}"
    echo "${QUOTE}" | grep --color "$WORD"
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
  WORDLIST_QUERY="SELECT stem 
    FROM words
    WHERE category$CATEGORY
    ORDER BY timestamp DESC"
  WORDS=$(sqlite3 -newline ' ' $DB "$WORDLIST_QUERY")
  echo $WORDS
}
