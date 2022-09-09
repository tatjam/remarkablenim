import nimx/types
import std/tables

type RemarkableColor = enum 
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

type Preset* = ref object 
    name: string
    icon: string
    icon_tint: Color
    color_map: Table[RemarkableColor, Color]
    color_exports: Table[RemarkableColor, bool]
    tool_settings: array[RemarkableTool, ToolSettings]
    use_text_ocr: bool

    export_templates: bool
    export_note_pages: bool
    export_base_pages: bool
    
