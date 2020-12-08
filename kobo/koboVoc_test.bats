#!/usr/bin/evn bats

setup(){
  . "./koboVoc.sh" "sample/KoboReader.sqlite"
  installDeps
}

@test "readWords" {
    words=$(selectWords)
    echo "current words: $words" >&1
    [[ " ${words[@]} " =~ "whiskers" ]] #contains at least 'inconclusive'
}

@test "quoting" {
    quote=$(quoteBook "whiskers")
    echo "current quote: '${quote}'" >&1
    [[ "$quote" = "“Oh my ears and whiskers, how late it’s getting!”"* ]]
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