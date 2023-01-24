import std/parseopt
import std/strutils
import ../tablet/filesystem
import std/terminal
import ls
import download
import ../document/preset

proc split_strings(a: string): seq[string] = 
    var buffer = ""
    var in_string = false
    for ch in a:
        if ch == '"':
            in_string = not in_string
        elif (ch == ' ' and not in_string):
            result.add(buffer)
            buffer = ""
        else:
            buffer = buffer & ch
    result.add(buffer)


proc launch_interactive*() = 
    # Download the filesystem
    var fsroot = get_filesystem_root(false)
    var tree: seq[Element]
    tree.add(fsroot)
    var preset = def_preset()
    while true:
        var cur_dir = "/"
        for elem in tree:
            cur_dir = cur_dir & elem.name & "/"
        stdout.styledWrite(fgCyan, cur_dir & " $ ")
        let input = readLine(stdin).splitStrings() 
        var valid = false
        if input.len == 1:
            if input[0] == "ls":
                ls(tree[tree.len - 1])
                valid = true
            elif input[0] == "exit":
                break
            elif input[0] == "help":
                echo "ls - Displays contents of current dir"
                echo "cd [dir] - Moves into a directory"
                echo "save [file/dir] [destination] - Saves file into destination in your PC"
                echo "sync - Does sync with all files, same as done by the GUI"
                echo "setpreset [preset] - Set preset to a given one"
                echo "lspresets - Display all usable presets"
                valid = true
        elif input.len == 2:
            if input[0] == "cd":
                var found = false
                if input[1] == ".." and tree.len > 1:
                    found = true
                    valid = true
                    discard tree.pop()
                else:
                    for elem in tree[tree.len - 1].children:
                        if elem.name == input[1]:
                            if elem.el_type == ElementType.FolderElem:
                                tree.add(elem)
                                valid = true
                                found = true
                            else:
                                stdout.styledWriteLine(fgRed, "Cannot move into element")
                if not found:
                    stdout.styledWriteLine(fgRed, "Could not find element")
        elif input.len == 3:
            if input[0] == "save":
                var found = false
                var telem: Element
                if input[1] == ".":
                    found = true
                    valid = true
                    telem = tree[tree.len - 1]
                else:
                    for elem in tree[tree.len - 1].children:
                        if elem.name == input[1]:
                            telem = elem
                            valid = true
                            found = true
                if not found:
                    stdout.styledWriteLine(fgRed, "Could not find element")
                else:
                    download(telem, input[2], true, preset)

        if not valid:
            stdout.styledWriteLine(fgRed, "Invalid command")
        
        # We support ls [dir] cd [dir] save [file/dir] [to]

