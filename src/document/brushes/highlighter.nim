import nimPDF/nimPDF
import ../lines

# color is already set in stroke and fill color
proc draw_highlighter*(x: Stroke, to: var PDF, scale: float) = 
    to.saveState()

    # TODO: Doesn't quite match remarkable results
    to.setLineWidth(scale * 3.0)
    to.setLineCap(SQUARE_END)
    to.setLineJoin(BEVEL_JOIN)
    to.setAlpha(0.5)
    to.setBlendMode(BM_OVERLAY)
    to.moveTo(x.segments[0].x * SCALE_FACTOR, x.segments[0].y * SCALE_FACTOR)
    for i in 1..(x.segments.len - 1):
        let next = x.segments[i]
        to.lineTo(next.x * SCALE_FACTOR, next.y * SCALE_FACTOR) 
    to.stroke()

    to.restoreState()