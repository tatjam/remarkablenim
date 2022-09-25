import nimPDF/nimPDF
import ../lines

# color is already set in stroke and fill color
proc draw_fineliner*(x: Stroke, to: var PDF, scale: float) = 
    to.saveState()

    # Values found by guesstimation
    to.setLineWidth(scale * 0.4)
    to.setLineCap(ROUND_END)
    to.setLineJoin(MITER_JOIN)
    to.setMiterLimit(1.0)
    to.moveTo(x.segments[0].x * SCALE_FACTOR, x.segments[0].y * SCALE_FACTOR)
    for i in 1..(x.segments.len - 1):
        let next = x.segments[i]
        to.lineTo(next.x * SCALE_FACTOR, next.y * SCALE_FACTOR) 
    to.stroke()

    to.restoreState()