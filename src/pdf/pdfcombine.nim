# Allows adding pages to PDF files / adding content on top of existing pages
# very barebones implementation, it would be a better idea to wrap a PDF library that
# can read files, but it works
import std/tables
import std/streams
import std/parseutils
import std/strutils
import json

type PDFObjType = enum
    ARRAY,
    TABLE,
    OTHER

# We only really care about array and table objects
type PDFObj = ref object
    case kind: PDFObjType
    of ARRAY:
        elems: seq[PDFObj]
    of TABLE:
        children: Table[string, PDFObj]
    of OTHER: discard


type PDFMap = ref object
    objects: seq[PDFObj]

# Ignores comments
proc get_next_line(f: FileStream): string = 
    var in_comment = false
    var line_start = true
    var c: char
    var line: string
    while true:
        c = f.readChar()
        line.add(c)
        if c == '%' and line_start == true:
            in_comment = true

        if line_start == true:
            line_start = false

        if c == '\n':
            line_start = true
            if not in_comment:
                return line
            in_comment = false
            line = ""

# We convert the weird syntax into JSON and parse it
proc parse_table(f: FileStream): JsonNode =
    var as_json = "{"
    var depth = 0
    assert f.get_next_line().startsWith("<<")
    while true:
        let line = f.get_next_line().unindent()
        if line.startsWith(">>"):
            # remove ',' from last elem
            as_json.delete(as_json.len - 2, as_json.len - 2)
            if depth != 0:
                as_json.add("},\n")
                depth = depth - 1
                continue
            else:
                as_json.add("}\n")
                echo as_json
                return parseJson(as_json)
        var separator_loc = line.find(" ")
        assert separator_loc >= 0
        var key = line.substr(1, separator_loc)
        as_json.add("\"" & key & "\": ")
        # Value is a bit more complicated as it may be many stuff, but for parsing
        # we lump everything into a string EXCEPT sub dictionaries
        var value = line.substr(separator_loc + 1)
        value.removeSuffix({'\n', '\r', ' '})
        if value.startsWith("<<"):
            depth = depth + 1
            as_json.add("{\n")
        else:
            as_json.add("\"" & value & "\",\n")



# TODO: This could break on HUGE pdf files?
proc get_uid(first_num: int, second_num: int): uint64 =
    return first_num.uint64 + second_num.uint64 * 4294967296'u64

# We only parse obj streams. TODO: This could fail on some very weird PDFs
proc parse_pdf*(path: string): PDFMap =
    var file = newFileStream(path, fmRead)

    while true:
        var line = file.get_next_line()
        # Parse an object
        if line.endsWith(" obj\n") or line.endsWith(" obj\r\n"):
            # First line defines object ID
            var first_num, second_num: int
            let advance = line.parseInt(first_num)
            line = line.substr(advance)
            discard line.parseInt(second_num)
            let object_uid = get_uid(first_num, second_num)

            # next lines should be a table
            let table = file.parse_table()


    file.close()

# page_map indicates wether a page in over goes into a new page (true)
# or if it goes over the old page (ie an overlay)
# Afterwards we COULD linearize or optimize the PDF for performance, but for relatively
# small updates (which these are, a few lines on top of a long pdf) it should be good
proc overlap_pdf*(base: string, over: string, page_map: seq[bool]) = 
    discard