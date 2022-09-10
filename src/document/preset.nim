import nimx/types
import std/tables
import uuids
import eminim
import std/streams
import std/os

type RemarkableColor* = enum 
    BLACK,
    GRAY,
    WHITE,
    HIGHLIGHT_YELLOW,
    HIGHLIGHT_PINK,
    HIGHLIGHT_GREEN,
    BLUE,
    RED

# Includes rmhacks tools
type RemarkableTool* = enum 
    BRUSH,
    PENCIL,
    BALLPOINT,
    MARKER,
    FINELINER,
    HIGHLIGHTER,
    ERASER,
    MECHANICAL,
    ERASER_AREA,
    CALLIGRAPHY,
    UNKNOWN

# This is used as the index LUT for the .lines files
let pen_lut = [BRUSH, PENCIL, BALLPOINT, MARKER, FINELINER, HIGHLIGHTER, ERASER, MECHANICAL,
    ERASER_AREA, UNKNOWN, UNKNOWN, UNKNOWN, BRUSH, MECHANICAL, PENCIL, BALLPOINT, MARKER,
    FINELINER, HIGHLIGHTER, ERASER, UNKNOWN, CALLIGRAPHY]

type ToolSettings* = ref object 
    does_export: bool
    draw_scale: float
    # Non present entries use the color_map
    color_map: Table[RemarkableColor, Color]
    # What does this tool draw like? To use custom drawings or remap stuff
    draw_mode: RemarkableTool

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
    result.icon = "notebook.png"
    result.icon_tint = (1.0'f32, 1.0'f32, 1.0'f32, 1.0'f32)
    result.color_map[BLACK] = (0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32)
    result.color_map[GRAY] = (0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32)
    result.color_map[WHITE] = (0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32)
    result.color_map[HIGHLIGHT_YELLOW] = (0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32)
    result.color_map[HIGHLIGHT_PINK] = (0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32)
    result.color_map[HIGHLIGHT_PINK] = (0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32)
    result.color_map[BLUE] = (0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32)
    result.color_map[RED] = (0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32)
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

proc save_preset*(preset: Preset) =
    let file = newFileStream("./presets/" & preset.uuid & ".json", fmWrite)
    file.storeJson(preset)
    file.close()