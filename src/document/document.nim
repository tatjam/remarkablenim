import lines
import std/json
import std/streams

type Document* = ref object
    Pages: seq[Page]


# Assumes all needed files are downloaded
proc generate*(path: string): Document =
    let contents = parseFile("./retmp/data/" & path & ".content")
    let pages = contents["pages"]
    for page in pages.items:
        let strm = newFileStream("./retmp/data/" & path & "/" & page.getStr & ".rm")
        let page = load_page(strm).get()
        strm.close()
