#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OXFORD_TXT="$DIR/oxford.txt"

function installDeps()
{
  if ! [ -f "$OXFORD_TXT" ]; then
    wget -O "$OXFORD_TXT" "https://raw.githubusercontent.com/sujithps/Dictionary/master/Oxford%20English%20Dictionary.txt"
  fi
}

function oxford()
{
  installDeps
  WORD=$1
  # case insensiti3ve search
  grep -i -E "^${WORD}" $OXFORD_TXT
}
