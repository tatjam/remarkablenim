import weave
import deques
import std/[os, osproc, options, json]
import .. /tablet/downloader


proc download*(path: string, preset: Preset): Flowvar[Document] = 
    return spawn download_worker(path, preset)