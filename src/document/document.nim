import nimPDF/nimPDF except Page
import lines
import std/json
import std/streams
import preset
import std/tables
import std/options
import eminim
import uuids

type Document* = ref object
    path: string
    has_base_pdf: bool
    # For each page in the generated PDF, does the page go on top of the 
    # original PDF, or is it a note page (true)?
    page_map: seq[bool]
    pages: seq[Page]
    preset: Preset


# Assumes all needed files are downloaded
proc generate*(path: string, preset: Preset): Document =
    result = new(Document)
    result.path = path

    result.preset = preset

    let contents = parseFile("./retmp/data/" & path & ".content")
    let pages = contents["pages"]
    for page in pages.items:
        let strm = newFileStream("./retmp/data/" & path & "/" & page.getStr & ".rm")
        var npage = new(Page)
        # PDF files may not actually have the files if the page is empty, we generate
        # it anyway as we will superimpose the pdf files later
        if strm.isNil:
            discard
        else:
            npage = load_page(strm).get()
            strm.close()
        result.pages.add(npage)

proc generate_pdf*(x: Document, to_path: string) = 
    var doc = newPDF()
    var tmp_path = to_path    
    if x.has_base_pdf:
        tmp_path = "./retmp/" & x.path & "-tmp.pdf"

    for page in x.pages:
        doc.addPage(PageSize(width: fromMM(SCREEN_WIDTH), height: fromMM(SCREEN_HEIGHT)), PGO_PORTRAIT)
        page.draw(doc, x.preset)

    var file = newFileStream(tmp_path, fmWrite)
    doc.writePDF(file)
    file.close()

    if x.has_base_pdf:
        # Combine the two
        discard