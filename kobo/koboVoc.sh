#!/bin/bash

DB=$1
KDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function installDeps()
{
  if ! [ -x "$(command -v epub2txt)" ]; then
    echo 'installing epub2txt'
    if ! [ -d "epub2txt2" ]; then
      git clone https://github.com/kevinboone/epub2txt2
    fi
    dir=$(pwd)
    cd epub2txt2
    sudo make install
    cd $dir
  fi
}

function quoteBook()
{
   epubPath=$(selectBook $1)
   book=$(basename "$epubPath") 
   # copy locally or read from remote
   epub2txt "$KDIR/sample/$book" | grep $1
}

function archive()
{
  WORD=$1
  ARCHIVE_SQL="UPDATE WORDS 
      SET category=100 
      WHERE stem='$WORD';"
  sqlite3 $DB "$ARCHIVE_SQL"
}

function selectBook()
{
  WORD=$1
  WORDLIST_QUERY="SELECT VolumeId 
    FROM WordList
    WHERE text='$WORD'
    LIMIT 1;"
  WORDS=$(sqlite3 -newline ' ' $DB "$WORDLIST_QUERY")
  echo $WORDS
}

function selectWords()
{
  # 'DictSuffix to limit lang'
  WORDLIST_QUERY="SELECT DISTINCT text 
    FROM WordList
    ORDER BY DateCreated DESC"
  WORDS=$(sqlite3 -newline ' ' $DB "$WORDLIST_QUERY")
  echo $WORDS
}
