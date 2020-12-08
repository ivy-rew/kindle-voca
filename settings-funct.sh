#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function initSettings()
{
  settings="$DIR/settings.conf"
  if ! [ -f "$settings" ]; then
    echo "No settings found at '$settings' using '$(basename ${settings}.template)'"
    echo "Setup your actual environment by copying the template to '$(basename $settings)' and adjust it to your preferences."
    settings="${settings}.template"
  fi
  . "$settings"
}