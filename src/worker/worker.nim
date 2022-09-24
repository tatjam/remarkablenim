import weave
import deques
import std/[os, osproc, options]

import ../document/document

# returns true if failed, if ext = "/", then we are copying a folder
proc download(path: string, ext: string): bool =
    let rm_path = "root@10.11.99.1:/home/root/.local/share/remarkable/xochitl/" & path & ext
    let pc_path = "./retmp/data/" & path & ext
    var process: Process
    if ext == "/":
        process = startProcess("scp", "", ["-r", "-o", "ConnectTimeout=1", rm_path, pc_path])
    else:
        process = startProcess("scp", "", ["-o", "ConnectTimeout=1", rm_path, pc_path])

    let code = process.waitForExit
    if code != 0:
        return true

    return false


# multiple scp instances can run without problem, so we spawn as many as needed
# (Note that this will always work with directories!)
# May return nil!
proc download_worker(path: string): Document =
    # We first download the .content to investigate other needed files
    #[if download(path, ".content"):
        return nil

    # Investigate (TODO)


    # Download all pages
    if download(path, "/"):
        return nil
    ]#
    # We generate the document from this, this is also an "expensive" operation

    # And the contents file
    #removeFile("./retmp/data/" & path & ".contents")
    # And other used files / folder
    # We may now remove the folder
    #removeDir("./retmp/data/" & path)

    return nil


proc download*(path: string): Flowvar[Document] = 
    return spawn download_worker(path)