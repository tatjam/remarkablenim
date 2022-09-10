# Linked list of all folders and files
import std/osproc
import std/options
import std/json

type
    ElementType* = enum
        Root
        Folder
        Document
        
    Element* = ref object
        Path*: string
        Name*: string
        Modify*: int
        StrParent: string
        Parent*: Option[Element]
        case Type: ElementType
        of Document: discard
        of Root, Folder: Children*: seq[Element]
            

proc create_root(): Element = 
    return Element(Path: "root", Name: "root", Parent: none(Element))


proc create_base_from_json(path: string, j: JsonNode): Option[Element] = 
    if j["deleted"].bval == true:
        return none(Element)
    else:
        if j["parent"].kind == JString and (j["parent"].str == "trash"):
            return none(Element)
        case j["type"].str
        of "CollectionType":
            return some(Element(Path: path, Name: j["visibleName"].str, Modify: parseInt(j["lastModified"].getStr("0")),
                Parent: none(Element), Type: Folder, Children: newSeq[Element](), StrParent: j["parent"].getStr("root")))
        of "DocumentType":
            return some(Element(Path: path, Name: j["visibleName"].str, Modify: parseInt(j["lastModified"].getStr("0")),
                Parent: none(Element), Type: Document, StrParent: j["parent"].getStr("root")))


# All paths are prefixed with /home/root/.local/share/remarkable/xochitl/
# Returns the root element of the file system
proc load_filesystem*(): Element =
    # We only get the .metadata files for now, we copy all at once as they are lightweight
    # Using the wildcard feature on scp, we can obtain all .metadata
    
    # First, remove all tmp contents
    #removeDir("./retmp/");
    #createDir("./retmp/");
    
    # We may now copy everything over, we do this synchronous because it should be fast
    #let command = "scp -q root@10.11.99.1:/home/root/.local/share/remarkable/xochitl/*.metadata ./retmp/"
    #let res, code = execCmdEx(command)
    var root = create_root()
    var all_rm_elems: seq[Element]

    for kind, path in walkDir("./retmp/", true):
        if kind != pcFile: continue
        # As we load relatives, path is simply the filename
        let file = parseJson(readFile("./retmp/" & path))
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
                if slem.Type != Folder: continue
                if slem.Path == elem.StrParent:
                    elem.Parent = some(slem)
                    slem.Children.add(elem)

    return root
    