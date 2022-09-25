import nigui
import ../document/preset

load_presets()

import weave

init(Weave)

import ../worker/worker
import ../document/document

#[let x = download("4c6d28dc-72d8-41b8-bd39-d1988eea482d")
let doc = sync(x)
doc.generate_pdf("output.pdf")]#


let y = download("d4bd814c-dc0c-4352-b3bd-e37e8b6576d1")
let doc2 = sync(y)
doc2.generate_pdf("output-pdf.pdf")

import notebooks_view

let MARGINS* = 8
let STATUS_SIZE* = 28
let BUTTONS_SIZE* = 32


var selected_preset*: string


app.init()

var win = newWindow("Remarkable Nim")

win.width = 800.scaleToDpi
win.height = 600.scaleToDpi

# The window always shows the status bar and a layout container for the other stuff
var container = newLayoutContainer(Layout_Vertical)
win.add(container)

var main_container = newLayoutContainer(Layout_Vertical)
container.add(main_container)


var status_container = newLayoutContainer(Layout_Vertical)
container.add(status_container)
status_container.yAlign = YAlign_Bottom
status_container.xAlign = XAlign_Center
status_container.spacing = -18

var status_label = newLabel("Standby")
status_container.add(status_label)
# Make sure the progress bar is visible behind the text
status_label.backgroundColor = rgb(0, 0, 0, 0)


var progbar = newProgressBar()
status_container.add(progbar)

# Dummy container to allow deletion without order change
var dummy_container = newLayoutContainer(Layout_Vertical)
main_container.add(dummy_container)

proc goto_view(view: string, meta: string = "") = 
    main_container.remove(dummy_container)
    case view:
    of "notebooks": dummy_container = load_notebooks_view(win, meta)
    else: echo "Invalid view"
    main_container.add(dummy_container)

goto_view("notebooks")

win.show()


app.run()

exit(Weave)