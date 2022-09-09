import nimx/[layout,button, text_field]
import sugar
import base
import dropdown_inverted

var goto_presets* = false


proc load_notebooks_view*(into: View, change: (string, string) -> void) = 
    into.makeLayout:
        - Button as multi_button:
            trailing == super.trailing - MARGINS
            leading == super.trailing - MARGINS - 150.0
            top == super.bottom - BUTTONS_SIZE - MARGINS
            bottom == super.bottom - MARGINS
            title: "Multi"
        - Button as sync_button:
            trailing == prev.leading - MARGINS 
            leading == prev.leading - MARGINS - 150.0
            top == prev.top
            bottom == prev.bottom
            title: "Sync Settings"
        # The majority of the view is the browser 
        # Below we have the preset chooser popup button
        - DropdownInverted as preset_chooser:
            left == super.leading + MARGINS
            right == prev.leading - MARGINS
            top == prev.top
            bottom == prev.bottom
            items: ["Hello, world", "Goodbye, world"]
            onAction:
                change("preset_select", "")
    

