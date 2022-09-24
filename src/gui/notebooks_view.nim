import nigui
import std/unicode
import std/encodings
import std/sets
import std/tables
import stacks
import std/times

import ../tablet/filesystem
import ../document/preset

var notebooks_text: string
var line_to_elem: Table[int, Element]
var open_folders: HashSet[Element]

# double click detection
var last_click_time: float
var last_click_line = -1

# TODO: Choose a reasonable size
proc sorten(x: string): string = 
    if x.len > 80:
        return x.substr(0, 80) & "..."
    else:
        return x

proc generate(): void = 
    notebooks_text = ""

    let fsroot = get_filesystem_root(true)
    # Walk the directory downwards (depth first traversal algorithm)
    var S: Stack[Element]
    var depths: Stack[int]
    var visited: HashSet[Element]
    S.push(fsroot)
    depths.push(-1)
    var line = 0

    while not S.isEmpty:
        let v = S.pop()
        let curdepth = depths.pop()
        if not visited.contains(v):
            visited.incl(v)
            if v.Type != RootElem:

                var indent = ""
                for i in 0..(curdepth - 1):
                    indent = indent & "  "

                if v.Type == FolderElem:
                    var filename = "📁 " & v.Name
                    notebooks_text = notebooks_text & indent & sorten(filename) & "\p"
                else:
                    var filename = all_presets[parseUUID(v.Preset)].icon & " " & v.Name
                    notebooks_text = notebooks_text & indent & sorten(filename) & "\p"

                line_to_elem[line] = v
                line = line + 1

            if (v.Type == FolderElem and open_folders.contains(v)) or v.Type == RootElem:
                for child in v.Children:
                    S.push(child)
                    depths.push(curdepth + 1)




proc load_notebooks_view*(win: Window, meta: string): LayoutContainer =
    let basecont = newLayoutContainer(Layout_Vertical)
    basecont.heightMode = HeightMode_Expand
    # List of files
    let cont = newLayoutContainer(Layout_Vertical)
    let tree = newTextArea("")
    tree.heightMode = HeightMode_Expand
    tree.fontFamily = "Consolas"
    tree.fontSize = 20
    tree.editable = false


    cont.add(tree)
    # Buttons and chooser
    let subcont = newLayoutContainer(Layout_Horizontal)
    subcont.yAlign = YAlign_Bottom
    #subcont.heightMode = HeightMode_Fill
    var presets: seq[string]
    presets.add("Hello")
    presets.add("world")
    var dropdown = newComboBox(presets)
    dropdown.widthMode = WidthMode_Expand
    subcont.add(dropdown)

    var sync_opts = newButton("Sync Options")
    #sync_opts.height = 28
    subcont.add(sync_opts)
    
    var multibut = newButton("Upload to")
    multibut.onClick = proc(event: ClickEvent) = 
        var selected: Element = nil 
        if last_click_line < 0 or (selected = line_to_elem[last_click_line]; selected).Type == FolderElem:
            var dialog = newOpenFileDialog()
            dialog.title = "File location"
            dialog.multiple = true
            dialog.run()
            for file in dialog.files:
                echo file
        else:
            var dialog = SaveFileDialog()
            dialog.title = "Destination location"
            dialog.defaultName = selected.Name & ".pdf"
            dialog.run()
            echo dialog.file

    #multibut.height = 28
    subcont.add(multibut)
    
    basecont.add(cont)
    basecont.add(subcont)
    
    tree.onClick = proc(event: ClickEvent) =
        # text is in UTF-8 conveniently
        var text = tree.text
        var pos = tree.cursorPos
        var rbyte = 0
        var lbyte = 0
        var lengths_up_to_lbyte: seq[int]
        # positions are in characters and not bytes!
        # find rbyte and lbyte (emojis take 2 pos for wathever reason)
        while pos > 0:
            if text.runeLenAt(rbyte) == 4:
                pos = pos - 2
            else:
                pos = pos - 1 
            lengths_up_to_lbyte.add(text.runeLenAt(rbyte))
            rbyte = rbyte + text.runeLenAt(rbyte)

        lbyte = rbyte
        if rbyte == text.len:
            return
        
        # Find the line by counting \n up to the desired point
        var line = 0
        for i in 0..lbyte:
            if text[i] == '\n':
                line = line + 1
        
        if line_to_elem[line].Type == FolderElem:
            multibut.text = "Upload to"
        else:
            multibut.text = "Download"

        let dur = cpuTime() - last_click_time
        last_click_time = cpuTime()

        # Double clicking opens folders
        if line == last_click_line and dur < 0.4:
            var elem = line_to_elem[line]
            if elem.Type == FolderElem:
                if open_folders.contains(elem):
                    open_folders.excl(elem)
                else:
                    open_folders.incl(elem)
                generate()
                tree.text = notebooks_text
                return

        last_click_line = line

        var rpos = tree.cursorPos
        while true:
            if text[rbyte] == '\n':
                break
            rbyte = rbyte + text.runeLenAt(rbyte)
            # For wathever reason emojis take 2 positions, keep this in mind!
            if text.runeLenAt(rbyte) == 4:
                rpos = rpos + 2
            else:
                rpos = rpos + 1
        
        var lpos = tree.cursorPos
        while true:
            if lengths_up_to_lbyte.len == 0 or text[lbyte] == '\n':
                break
            let length = lengths_up_to_lbyte[^1]
            lbyte = lbyte - length
            lengths_up_to_lbyte.delete(lengths_up_to_lbyte.len - 1)
            if length == 4:
                lpos = lpos - 2
            else:
                lpos = lpos - 1
        tree.selectionStart = lpos
        tree.selectionEnd = rpos

    generate()
    # We need to delay a bit until app is actually started to try and get text
    startTimer(10, proc(event: TimerEvent) =
        tree.text = notebooks_text)
    win.onResize = proc(event: ResizeEvent) =
        tree.text = notebooks_text
    return basecont