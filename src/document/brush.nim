
type RemarkableColor* = enum 
    BLACK,
    GRAY,
    WHITE,
    HIGHLIGHT_YELLOW,
    HIGHLIGHT_PINK,
    HIGHLIGHT_GREEN,
    BLUE,
    RED,
    HIGHLIGHT_OVERLAP

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
let pen_lut* = [BRUSH, PENCIL, BALLPOINT, MARKER, FINELINER, HIGHLIGHTER, ERASER, MECHANICAL,
    ERASER_AREA, UNKNOWN, UNKNOWN, UNKNOWN, BRUSH, MECHANICAL, PENCIL, BALLPOINT, MARKER,
    FINELINER, HIGHLIGHTER, ERASER, UNKNOWN, CALLIGRAPHY]

