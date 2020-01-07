#!/bin/bash

DB="sample/vocab.db"

function quoteBook()
{
  WORD=$1
  BOOK_QUERY="SELECT l.usage, b.title, b.authors FROM LOOKUPS l
JOIN BOOK_INFO b ON b.id = l.book_key
WHERE l.word_key == 'en:$WORD'"
  QUOTE=$(sqlite3 $DB "$BOOK_QUERY")
  grep --color $WORD <<< $QUOTE
}

function archive()
{
  WORD=$1
  ARCHIVE_SQL="UPDATE WORDS 
      SET category=100 
      WHERE word='$WORD';"
  sqlite3 $DB "$ARCHIVE_SQL"
}

function ask()
{
  WORD=$1
  echo $WORD
  quoteBook $WORD
  select OPERATION in 'next' 'archive' 'quote (kindle)' 'lookup (leo)'
    do
        if [ "$OPERATION" == "lookup (leo)" ]; then
            echo "asking leo for meaning of: $WORD"
            leo ${WORD}
        fi
        if [ "$OPERATION" == "quote (kindle)" ]; then
            quoteBook $WORD
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

function selectWords()
{
  CATEGORY=$1
  WORDLIST_QUERY="SELECT word 
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

function installDeps()
{
  if ! [ -x "$(command -v leo)" ]; then
    sudo apt install -y libwww-dict-leo-org-perl
  fi
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
