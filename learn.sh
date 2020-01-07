#!/bin/bash

DB="sample/vocab.db"

function quoteBook()
{
  WORD=$1
  BOOK_QUERY="SELECT l.usage, b.title, b.authors FROM LOOKUPS l
JOIN BOOK_INFO b ON b.id = l.book_key
WHERE l.word_key == 'en:$WORD'"
  sqlite3 $DB "$BOOK_QUERY"
}

function ask()
{
  WORD=$1
  echo $WORD
  select OPERATION in 'learned' 'quote (kindle)' 'lookup (leo)'
    do
        if [ "$OPERATION" == "lookup (leo)" ]; then
            echo "asking leo for meaning of: $WORD"
            leo ${WORD}
        fi
        if [ "$OPERATION" == "quote (kindle)" ]; then
            quoteBook $WORD
        fi
        if [ "$OPERATION" == "learned" ]; then
            break;
        fi
  done
}

function main()
{
    WORDLIST_QUERY="SELECT substr(l.word_key, 4) as word FROM LOOKUPS l"
    WORDS=$(sqlite3 -newline ' ' $DB "$WORDLIST_QUERY")
    for WORD in $WORDS
    do
      ask $WORD
    done
}

main
