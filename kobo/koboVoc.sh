#!/bin/bash

DB=$1; DEVICE=$2

KDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
bookCache="$KDIR/.bookCache"

function installDeps()
{
  if ! [ -x "$(command -v epub2txt)" ]; then
    echo 'installing epub2txt'
    if ! [ -d "epub2txt2" ]; then
      git clone https://github.com/kevinboone/epub2txt2
    fi
    cd epub2txt2
    make
    sudo make install
    cd $KDIR
  fi
}

function quoteBook()
{
  word=$1
  book=$(bookOfWord $word)
  usage=$(findUsage "$book" "$word")
  highlight "$usage" "$word"
  bookDesc "$book"
}

function findUsage()
{
  book=$1; word=$2; 
  match=$(epub2txt --noansi --raw "$book" | grep -m 1 "$word")
  quote=$(sentence "$match" "$word")
  echo "$quote"
}

function sentence()
{ # enforce newlines after punctuation: and not by epub magic!
  quote="$1"; word="$2"
  echo "$quote" | \
    sed -e "s#\([\.|\?|\!|\:|”] \)#\1\n#g" | \
    sed -e "s#\( [“]\)#\n\1#g" | \
    awk '{$1=$1; print}' | \
    grep "$word"
}

function bookOfWord()
{
  epubPath=$(selectBook $1)
  book=${epubPath#'file:///mnt/onboard/'}
  bookPath="$bookCache/$book"
  if ! [ -f "$bookCache/$book" ]; then
    devicePath="$DEVICE/$book"
    if ! [ -f "$devicePath" ]; then
      echo "failed to load ${devicePath}"
      echo "is your Kobo device mounted? Does it match the 'settings.conf' entry called 'kMount'?"
    else
      mkdir -p "$(dirname "$bookPath")"
      cp "$devicePath" "$bookPath"
    fi
  fi
  echo "$bookPath"
}

function highlight()
{
  input=$1; highlight=$2
  start=$(tput setaf 1)
  if [ ! -z "$3" ]; then
    start="${3}"
  fi
  end=$(tput sgr0)
  if [ ! -z "$4" ]; then
    end="${4}"
  fi
  
  echo "${input}" | sed -e "s|$highlight|${start}${highlight}${end}|g"
}

function bookDesc()
{
  book=$1
  meta=$(epub2txt -m --notext "$book")
  author=$(metaValue "$meta" "Creator: ")
  title=$(metaValue "$meta" "Title: ")
  echo "${title}, ${author}"
}

function metaValue()
{
  meta=$1; field=$2
  echo "$meta" | grep "$field" | awk 'BEGIN{FS=":"}{print $2}' | awk '{$1=$1; print}'
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
  BOOKLANG="en" # prefix of the dict-lang: e.g. (fr, en, de, ...)
  if [ ! -z "$1" ]; then
    BOOKLANG="${1}"
  fi
  WORDLIST_QUERY="SELECT DISTINCT text 
    FROM WordList
    WHERE DictSuffix LIKE '-$BOOKLANG%'
    ORDER BY DateCreated DESC"
  WORDS=$(sqlite3 -newline ' ' $DB "$WORDLIST_QUERY")
  echo $WORDS
}
