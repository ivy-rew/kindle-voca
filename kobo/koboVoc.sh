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
    cd epub2txt2
    sudo make install
    cd $KDIR
  fi
}

function quoteBook()
{
   book=$(bookOfWord $1)
   epub2txt "$book" | grep -m 1 $1
   bookDesc "$book"
}

function bookOfWord()
{
  epubPath=$(selectBook $1)
  book=$(basename "$epubPath") 
  # copy locally or read from remote
  echo "$KDIR/sample/$book"
}

function bookDesc()
{
  book=$1
  meta=$(epub2txt -m --notext "$book")
  author=$(echo "$meta" | grep 'Creator: ')
  title=$(echo "$meta" | grep 'Title: ')
  echo "${title#*:},${author#*:}"
}

function archive()
{
  echo 'unsupported on kobo'
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
