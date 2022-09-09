import nimx/[window,layout,button, progress_indicator, text_field, timer]
import gui/notebooks_view
import gui/preset_select_view

let status_size = 28.0
let margins = 8.0

var stack: seq[string]
var next: string
var meta: string

proc startApp() =
    # Main window we use for everything, we create the basic layout
    var wnd = newWindow(newRect(40, 40, 800, 600))
    wnd.title = "Remarkable Nim"

    wnd.makeLayout:
        # Bottom progress bar and status
        - View as statusView:
            top == super.bottom - status_size
            bottom == super.bottom
            left == super.left
            right == super.right
            - ProgressIndicator as progressBar:
                top == super.top
                bottom == super.bottom - margins
                left == super.left + margins
                right == super.right - margins
            - Label as statusText:
                left == prev.left + 4.0
                centerY == prev.centerY
                width == 300
                height == 20.0
                text: "Standby"
        # This will be replaced
        - View as currentView:
            top == super.top + 100.0
            bottom == super.bottom - status_size
            left == super.left
            right == super.right

    proc on_view_change(to: string, nmeta: string): void = 
        next = to
        meta = nmeta

    proc do_view_change(): void =
        if next == "": return
        currentView.removeAllSubviews()
        if next != "prev":
            stack.add(next)
        case next:
        of "notebooks": load_notebooks_view(currentView, on_view_change)
        of "preset_select": load_preset_select_view(currentView, meta, on_view_change)
        of "prev": 
            let top = stack[stack.len - 2]
            stack.setLen(stack.len - 1)
            next = top
            do_view_change()
        else: echo "Invalid view"
        next = ""
        meta = ""


    # This is probably not how this is meant to be used, but it works :P
    on_view_change("notebooks", "")

    # This little workaround is required, as we can't change the layout
    # during a button callback
    setInterval 0.05, do_view_change

# SDL entrypoint
runApplication:
    startApp()