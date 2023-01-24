import std/tables
import uuids
import eminim
import nigui
import std/streams
import std/os
import brush

export Color

type ToolSettings* = ref object 
    does_export*: bool
    draw_scale*: float
    # Non present entries use the color_map
    color_map*: Table[RemarkableColor, Color]
    # What does this tool draw like? To use custom drawings or remap stuff
    draw_mode*: RemarkableTool

proc def_tool_settings*(tool: RemarkableTool): ToolSettings = 
    ToolSettings(does_export: true, draw_scale: 1.0, color_map: initTable[RemarkableColor, Color](), draw_mode: tool)

type Preset* = ref object 
    uuid*: string
    name*: string
    icon*: string
    icon_tint*: Color
    color_map*: array[RemarkableColor, Color]
    color_exports*: array[RemarkableColor, bool]
    tool_settings*: array[RemarkableTool, ToolSettings]
    use_text_ocr*: bool

    export_templates*: bool
    export_note_pages*: bool
    export_base_pages*: bool
    
proc def_preset*(): Preset = 
    result = new(Preset)
    result.uuid = "66d6d990-2fd8-4e31-8260-a53c41a71429"
    result.name = "Default"
    result.icon = "📓"
    result.icon_tint = rgb(255, 255, 255, 255)
    result.color_map[BLACK] = rgb(0, 0, 0, 255)
    result.color_map[GRAY] = rgb(128, 128, 128, 255)
    result.color_map[WHITE] = rgb(255, 255, 255, 255)
    result.color_map[HIGHLIGHT_YELLOW] = rgb(255, 245, 168, 128)
    result.color_map[HIGHLIGHT_PINK] = rgb(255, 168, 254, 128)
    result.color_map[HIGHLIGHT_GREEN] = rgb(167, 255, 172, 255)
    result.color_map[HIGHLIGHT_OVERLAP] = rgb(0, 0, 0, 60)
    result.color_map[BLUE] = rgb(60, 89, 202, 255)
    result.color_map[RED] = rgb(202, 32, 32, 255)
    for color in RemarkableColor:
        result.color_exports[color] = true
    for tool in RemarkableTool:
        result.tool_settings[tool] = def_tool_settings(tool)
    result.use_text_ocr = false
    result.export_templates = true
    result.export_note_pages = true
    result.export_base_pages = true

var all_presets*: Table[UUID, Preset]

# Loads all the presets from the ./presets directory
proc load_presets*() =
    for kind, path in walkDir("./presets/", true):
        if kind != pcFile: continue
        # As we load relatives, path is simply the filename
        let file = newFileStream("./presets/" & path, fmRead)
        let preset = file.jsonTo(Preset)
        let uuid = preset.uuid.parseUUID()
        all_presets[uuid] = preset
        file.close()

proc storeJson*(s: Stream; m: byte) =
    storeJson(s, int(m))

proc save_preset*(preset: Preset) =
    let file = newFileStream("./presets/" & preset.uuid & ".json", fmWrite)
    file.storeJson(preset)
    file.close()
