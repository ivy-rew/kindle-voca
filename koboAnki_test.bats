#!/usr/bin/evn bats

setup(){
  . "anki.sh" "test"
  . "kobo/koboVoc.sh" "kobo/sample/KoboReader.sqlite" "kobo/sample"
  bookCache=/tmp/kobo #re-route: keep my real local cache!
  installDeps
}

@test "ankiQuote" {
    html=$(ankiQuote "whiskers")
    echo "current html: $html" >&1
    [[ "$html" == *"whiskers"* ]] 
}
