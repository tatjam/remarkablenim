# Linked list of all folders and files
import std/[options, json, strutils, os, osproc, hashes, algorithm, tables, streams]
import eminim
import uuids
import ../document/document

export uuids

# Invalidate as needed externally (set to None) so we reload it
var preset_assignment*: Option[Table[string, string]]

type
    ElementType* = enum
        RootElem
        FolderElem
        DocumentElem
        
    Element* = ref object
        Path*: string
        Name*: string
        Modify*: int
        StrParent: string
        Parent*: Option[Element]
        case Type*: ElementType
        of DocumentElem: 
            DocumentData: Document
            Preset*: string
        of RootElem, FolderElem: Children*: seq[Element]

proc hash*(x: Element): Hash =
    var h: Hash = 0
    h = h !& hash(x.Path)
    return !$h

proc create_root(): Element = 
    return Element(Path: "root", Name: "root", Parent: none(Element))

proc sort_children(e: var Element) = 
    if e.Type == FolderElem or e.Type == RootElem:
        e.Children.sort do (x, y: Element) -> int:
            # We alphabetic sort, but give priority to folders
            if x.Type == FolderElem and y.Type != FolderElem:
                result = 1
            elif x.Type != FolderElem and y.Type == FolderElem:
                result = -1
            else:
                result = -cmp(x.Name, y.Name)

proc create_base_from_json(path: string, j: JsonNode): Option[Element] = 
    if j["deleted"].bval == true:
        return none(Element)
    else:
        if j["parent"].kind == JString and (j["parent"].str == "trash"):
            return none(Element)
        case j["type"].str
        of "CollectionType":
            return some(Element(Path: path, Name: j["visibleName"].str, Modify: parseInt(j["lastModified"].getStr("0")),
                Parent: none(Element), Type: FolderElem, Children: newSeq[Element](), StrParent: j["parent"].getStr("root")))
        of "DocumentType":
            if preset_assignment.isNone:
                let file = newFileStream("./retmp/preset_assignment.json", fmRead)
                preset_assignment = some(file.jsonTo(Table[string, string]))
                file.close()

            let preset = preset_assignment.get.getOrDefault(path, "66d6d990-2fd8-4e31-8260-a53c41a71429")

            return some(Element(Path: path, Name: j["visibleName"].str, Modify: parseInt(j["lastModified"].getStr("0")),
                Parent: none(Element), Type: DocumentElem, StrParent: j["parent"].getStr("root"), Preset: preset))

var fs_root: Element

# All paths are prefixed with /home/root/.local/share/remarkable/xochitl/
# Returns the root element of the file system
proc load_filesystem*(from_cached = false): Element =
    # We only get the .metadata files for now, we copy all at once as they are lightweight
    # Using the wildcard feature on scp, we can obtain all .metadata
    
    # First, remove all tmp contents
    #[removeDir("./retmp/metadata");
    createDir("./retmp/metadata");
    
    # We may now copy everything over, we do this synchronous because it should be fast
    let command = "scp -q root@10.11.99.1:/home/root/.local/share/remarkable/xochitl/*.metadata ./retmp/metadata"
    let res, code = execCmdEx(command)]#
    var root = create_root()
    var all_rm_elems: seq[Element]

    for kind, path in walkDir("./retmp/metadata/", true):
        if kind != pcFile: continue
        # As we load relatives, path is simply the filename
        let file = parseJson(readFile("./retmp/metadata/" & path))
        let elem = create_base_from_json(path, file)
        if elem.isSome:
            all_rm_elems.add(elem.get())

    # We now create the tree structure (once all files are loaded)
    for elem in mitems(all_rm_elems):
        if elem.StrParent == "root" or elem.StrParent == "":
            elem.Parent = some(root)
            root.Children.add(elem)
        else:
            for slem in mitems(all_rm_elems):
                if slem.Type != FolderElem: continue
                if slem.Path.startsWith(elem.StrParent):
                    elem.Parent = some(slem)
                    slem.Children.add(elem)

    root.sort_children()
    for elem in mitems(all_rm_elems):
        elem.sort_children()

    fs_root = root
    return fs_root
    
# May load the filesystem if needed
proc get_filesystem_root*(from_cached = false): Element =
    if fs_root != nil:
        return fs_root
    else:
        return load_filesystem(from_cached)

# Will download needed files to retmp/data
proc get_document*(x: Element): Document = 
    return Document()

# Removes used files in retmp/data
proc clean_document*(x: Element) = 
    return