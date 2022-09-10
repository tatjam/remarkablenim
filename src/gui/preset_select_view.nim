import nimx/[layout,button, text_field, scroll_view, popup_button]
import sugar
import base

proc load_preset_select_view*(into: View, meta: string, change: (string, string) -> void) = 
    # At the bottom we locate the bottoms, at the top a scrollable list with
    # all existing presets
    #[into.makeLayout:
        - PopupButton as wathever:
            center == super
            width == 100.0
            height == 100.0
            items: ["Hello", "world"]
        - ScrollView as preset_list:
            top == super.top + MARGINS
            bottom == next.top
            left == super.left + MARGINS 
            right == super.right - MARGINS
        - Button as accept_button:
            trailing == super.trailing - MARGINS
            leading == super.trailing - MARGINS - 150.0
            top == super.bottom - BUTTONS_SIZE - MARGINS
            bottom == super.bottom - MARGINS
            title: "Accept"
            onAction:
                change("prev", "")
        - Button as edit_button:
            trailing == prev.leading - MARGINS 
            leading == prev.leading - MARGINS - 150.0
            top == prev.top
            bottom == prev.bottom
            title: "Edit"
            onAction:
                change("preset_edit", "")
        - Button as cancel_button:
            trailing == super.leading + MARGINS + 150.0 
            leading == super.leading + MARGINS
            top == prev.top
            bottom == prev.bottom
            title: "Cancel"
            onAction:
                change("prev", "")

    if meta == "no_edit":
        edit_button.disable
    ]#

    let pb = PopupButton.new(newRect(120, 90, 120, 20))
    pb.items = @["Popup button", "Item 1", "Item 2"]
    into.addSubview(pb)
    