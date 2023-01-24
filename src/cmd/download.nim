# Tool to download a file / whole folder from the remarkable to a destination 
import ../tablet/filesystem
import ../document/document
import ../tablet/downloader
import std/terminal
import std/strutils

proc download*(elem: Element, target: string, root: bool, preset: Preset) =
    var safe_str = target
    if target[target.len - 1] != '/':
        safe_str = safe_str & "/"
    if elem.el_type == ElementType.FolderElem or elem.el_type == ElementType.RootElem:
        for child in elem.children:
            var subdir = safe_str
            if not root:
                subdir = subdir & elem.name & "/"
            download(child, subdir, false, preset)
    else:
        let path = safe_str & elem.name & ".pdf"
        let safe_path = elem.path.substr(0, elem.path.rfind(".") - 1)
        let doc = download_file(safe_path, preset)
        if doc == nil:
            stdout.styledWriteLine(fgYellow, "Unable to download " & elem.name)
        else:
            echo "Generating pdf at: " & path
            doc.generate_pdf(path)
            

