import nigui

proc load_notebooks_view*(meta: string): LayoutContainer =
    let cont = newLayoutContainer(Layout_Vertical)
    let btn = newButton("Hello!")
    cont.add(btn)

    return cont