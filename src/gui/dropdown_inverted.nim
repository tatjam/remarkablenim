import nimx/control
export control
import nimx/menu
import nimx/composition
import nimx/context
import nimx/font
import nimx/layout
import nimx/view_event_handling
import nimx/scroll_view
import nimx/button

type DropdownInverted* = ref object of Control
    mItems: seq[MenuItem]
    mSelectedIndex: int

proc newDropdownInverted(r: Rect): DropdownInverted =
    result.new()
    result.init(r)

method init*(b: DropdownInverted, r: Rect) =
    procCall b.Control.init(r)
    b.mSelectedIndex = -1

proc `items=`*(b: DropdownInverted, items: openarray[string]) =
    let ln = items.len
    b.mItems.setLen(ln)
    if b.mSelectedIndex > ln - 1:
        b.mSelectedIndex = ln - 1
    elif b.mSelectedIndex == -1 and ln > 0:
        b.mSelectedIndex = 0
    for i, item in items:
        let it = item
        closureScope:
            let ii = i
            b.mItems[ii] = newMenuItem(it)
            b.mItems[ii].action = proc() =
                b.mSelectedIndex = ii
                b.sendAction(Event(kind: etUnknown))
                b.setNeedsDisplay()

proc newDropdownInverted*(parent: View = nil, position: Point = newPoint(0, 0), size: Size = newSize(100, 20), items: openarray[string]=[], selectedIndex: int=0): DropdownInverted =
    result = newDropdownInverted(newRect(position.x, position.y, size.width, size.height))
    result.mSelectedIndex = selectedIndex
    result.items = items
    if not isNil(parent):
        parent.addSubview(result)

proc selectedIndex*(b: DropdownInverted): int = b.mSelectedIndex
    ## Returns selected item index

proc selectedItem*(b: DropdownInverted): string = b.mItems[b.mSelectedIndex].title

proc `selectedIndex=`*(b: DropdownInverted, index: int) =
    ## Set selected item manually
    b.mSelectedIndex = index
    b.setNeedsDisplay()

var pbComposition = newComposition """
uniform vec4 uFillColorStart;
uniform vec4 uFillColorEnd;

float radius = 5.0;

void compose() {
    float stroke = sdRoundedRect(bounds, radius);
    float fill = sdRoundedRect(insetRect(bounds, 1.0), radius - 1.0);
    float buttonWidth = 20.0;
    float textAreaWidth = bounds.z - buttonWidth;
    vec4 textAreaRect = bounds;
    textAreaRect.z = textAreaWidth;

    vec4 buttonRect = bounds;
    buttonRect.x += textAreaWidth;
    buttonRect.z = buttonWidth;
    drawShape(stroke, newGrayColor(0.78));

    drawShape(sdAnd(fill, sdRect(textAreaRect)), newGrayColor(1.0));

    vec4 buttonColor = gradient(smoothstep(bounds.y, bounds.y + bounds.w, vPos.y),
        uFillColorStart,
        uFillColorEnd);
    drawShape(sdAnd(fill, sdRect(buttonRect)), buttonColor);

    drawShape(sdRegularPolygon(vec2(buttonRect.x + buttonRect.z / 2.0, buttonRect.y + buttonRect.w / 2.0 - 1.0), 4.0, 3, -PI/2.0), vec4(1.0));
}
"""

method draw(b: DropdownInverted, r: Rect) =
    pbComposition.draw b.bounds:
        setUniform("uFillColorStart", newColor(0.31, 0.60, 0.98))
        setUniform("uFillColorEnd", newColor(0.09, 0.42, 0.88))
    if b.mSelectedIndex >= 0 and b.mSelectedIndex < b.mItems.len:
        let c = currentContext()
        c.fillColor = blackColor()
        let font = systemFont()
        c.drawText(font, newPoint(4, b.bounds.y + (b.bounds.height - font.height) / 2), b.mItems[b.mSelectedIndex].title)

method onTouchEv(b: DropdownInverted, e: var Event): bool =
    if b.mItems.len > 0:
        case e.buttonState
        of bsDown:
            # We create a series of 
            b.makeLayout:
                - ScrollView as mytable:
                    left == super.left                    
                    right == super.right
                    bottom == super.bottom
                    top == super.top - 100.0

            let btn = newButton(newRect(0, 0, 100, 50))
            btn.title = "Hello"
            let btn2 = newButton(newRect(0, 100, 100, 50))
            btn2.title = "Bye"
            mytable.addSubview(btn)
            mytable.addSubview(btn2)
            mytable.updateLayout()
        else: discard

