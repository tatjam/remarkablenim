# Tool to inspect the remarkable filesystem from the command line
import ../tablet/filesystem
import terminal

proc ls*(fs: Element) =
    for val in fs.children:
        if val.el_type == ElementType.FolderElem:
            stdout.styledWriteLine(fgBlue, val.name & "/")
    for val in fs.children:
        if val.el_type == ElementType.DocumentElem:
            stdout.styledWriteLine(val.name)