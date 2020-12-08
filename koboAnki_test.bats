#!/usr/bin/evn bats

setup(){
  . "kobo/koboVoc.sh" "kobo/sample/KoboReader.sqlite" "kobo/sample"
  installDeps
  bookCache="/tmp/kobo" #re-route: keep my real local cache!
  . "anki.sh" "test"
}

@test "ankiQuote" {
    html=$(ankiQuote "whiskers")
    echo "current html: >>$html<<" >&1
    [[ "$html" == *"<b>whiskers</b>"* ]] 
    #[[ "$html" == "“Oh my ears and <b>whiskers</b>, how late it’s getting!”<br/><i class=\"ref\">Alice's Adventures in Wonderland, Lewis Carroll</i>"* ]]
}
