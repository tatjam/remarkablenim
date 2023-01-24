include std/osproc
include std/strutils

proc check_connection(): bool =
    # This uses a 1s timeout which is more than enough for USB communcations
    let command = "ssh -o ConnectTimeout=1 -q root@10.11.99.1 echo ping"
    let res, code = execCmdEx(command)
    return res.startsWith("ping")