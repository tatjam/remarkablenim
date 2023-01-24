import std/[os, osproc, options, json]

import ../document/document
import ../document/preset
import std/distros
import std/terminal

export preset

# returns true if failed, if ext = "/", then we are copying a folder
proc download(path: string, ext: string): bool =
    let rm_path = "root@10.11.99.1:/home/root/.local/share/remarkable/xochitl/" & path & ext
    let pc_path = "./retmp/data/" & path & ext
    var process: Process
    var exe_name = "/usr/bin/scp"
    if detectOs(Windows):
        exe_name = "scp"
    if ext == "/":
        process = startProcess(exe_name, "", ["-r", "-o", "ConnectTimeout=1", rm_path, pc_path])
    else:
        process = startProcess(exe_name, "", ["-o", "ConnectTimeout=1", rm_path, pc_path])

    let code = process.waitForExit
    if code != 0:
        return true

    return false

# multiple scp instances can run without problem, so we spawn as many as needed
# (Note that this will always work with directories!)
# May return nil!
proc download_file*(path: string, preset: Preset): Document =
    # We first download the .content to investigate other needed files
    if download(path, ".content"):
        stdout.styledWriteLine(fgRed, "Could not download .content")
        return nil
    # Investigate 
    let contents = parseFile("./retmp/data/" & path & ".content")

    # Base pdf file TODO
    if contents["fileType"].getStr == "pdf":
        return nil
        if download(path, ".pdf"):
            return nil
    # Download all pages
    if download(path, "/"):
        stdout.styledWriteLine(fgRed, "Could not downloadpagees")
        return nil
    # We generate the document from this, this is also an "expensive" operation
    let doc = generate(path, preset)

    # And the contents file
    #removeFile("./retmp/data/" & path & ".contents")
    # And other used files / folder
    # We may now remove the folder
    #removeDir("./retmp/data/" & path)

    return doc
