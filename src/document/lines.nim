# Understand the .lines file from remarkable.
# Supported version: 5
# We use little endian data!
# Based on RCU code

import std/[options, streams]
import brush
export options

type Segment* = object
    x, y, speed, direction, width, pressure: float32

type Stroke* = object 
    pen: RemarkableTool
    color: RemarkableColor
    width: float32
    segments: seq[Segment]

type Layer* = object 
    strokes: seq[Stroke]

type Page* = ref object 
    layers: seq[Layer]

proc load_segment(file: FileStream): Segment =
    result.x = file.readFloat32()
    result.y = file.readFloat32()
    result.speed = file.readFloat32()
    result.direction = file.readFloat32()
    result.width = file.readFloat32()
    result.pressure = file.readFloat32()


proc load_stroke(file: FileStream): Stroke = 
    let pen_int = file.readUInt32()
    result.pen = pen_lut[pen_int]
    let color_int = file.readUInt32()
    result.color = RemarkableColor(color_int)
    discard file.readInt32()
    result.width = file.readFloat32()
    discard file.readInt32()
    let nsegments = file.readUInt32()
    result.segments.setLen(nsegments)
    for i in 0..(nsegments - 1):
        result.segments[i] = file.load_segment()


proc load_page*(file: FileStream): Option[Page] = 
    var page = new(Page)
    # Check header
    if file.readStr(33) != "reMarkable .lines file, version=5":
        echo "Error parsing page, incorrect notebook version?"
        return none(Page)
    # Read more characters that are padding
    discard file.readStr(10)    
    # Read the number of layers
    let layers = file.readInt32()
    page.layers.setLen(layers)
    for l in 0..(layers - 1):
        # Number of strokes as unsigned 32 byte int
        let nstrokes = file.readUint32()
        page.layers[l].strokes.setLen(nstrokes)
        for s in 0..(nstrokes - 1):
            page.layers[l].strokes[s] = file.load_stroke()

    return some(page)



