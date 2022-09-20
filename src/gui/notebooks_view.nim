import nigui
import std/unicode
import std/encodings

proc generate_notebooks_text(): string = 
    # Header, expanded appropiately, contains
    # Rows contain
    # Padding Icon Filename
    var text = ""

    for i in 0..4:
        var filename = "a 📝 Filéteкo"
        #var filename = "File "
        text = text & filename & "\p"

    return text


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
    #multibut.height = 28
    subcont.add(multibut)
    
    basecont.add(cont)
    basecont.add(subcont)
    # We need to delay a bit until app is actually started to try and get text
    startTimer(10, proc(event: TimerEvent) =
        tree.text = generate_notebooks_text())
    win.onResize = proc(event: ResizeEvent) =
        tree.text = generate_notebooks_text()
    return basecont