#!/usr/bin/evn bats

setup(){
  . "./koboVoc.sh" "sample/KoboReader.sqlite" "sample"
  bookCache=/tmp/kobo #re-route: keep my real local cache!
  installDeps
}

@test "readWords" {
    words=$(selectWords)
    echo "current words: $words" >&1
    [[ " ${words[@]} " =~ "whiskers" ]] #contains at least 'inconclusive'
}

@test "wordUsage" {
    book=$(bookOfWord "whiskers")
    usage=$(findUsage "$book" "whiskers")
    echo "current usage: '${usage}'" >&1
    [[ "$usage" = "“Oh my ears and whiskers, how late it’s getting!”"* ]]
}

@test "bookMeta" {
    book=$(bookOfWord "whiskers")
    desc=$(bookDesc "$book")
    echo "current description: '${desc}'" >&1
    [ "$desc" = "Alice's Adventures in Wonderland, Lewis Carroll" ]
}

@test "bookOfWord" {
    book=$(bookOfWord "whiskers")
    echo "current book: ${book}" >&1
    [[ "$book" = *"Alice"* ]]
}

@test "sentence" {
    extract="introducing a discordant note, “the knavery already began at the train station.” An Italian boy who shared"
    quote=$(sentence "$extract" "knavery")
    echo "current quote: ${quote}" >&1
    [[ "$quote" = "“the knavery already began at the train station.”" ]]
}

@test "highlighting" {
    quote="Oh my ears and whiskers"
    word="ears"
    hightlighted=$(highlight "${quote}" "${word}" "<b>" "</b>")
    echo "current highlight: ${hightlighted}"
    [[ "$hightlighted" = "Oh my <b>ears</b> and whiskers" ]]
}

@test "loadBook" {
    word="whiskers"
    echo "cache is: $bookCache" >&1
    rm -rf "$bookCache"
    book=$(bookOfWord "whiskers")
    echo "book path: $book"
    [[ "$book" == "$bookCache/calibre/Carroll, Lewis/Alice_s Adventures in Wonderland - Lewis Carroll.kepub.epub" ]]
    [[ "$book" == "/tmp/"* ]]
}