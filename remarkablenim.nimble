# Package

version       = "0.1.0"
author        = "Tatjam"
description   = "A notebook tool for the Remarkable 2 tablet that uses external SSH tools."
license       = "MIT"
srcDir        = "src"
bin           = @["remarkablenim"]


# Dependencies

requires "nim >= 1.6.4"
requires "nimpdf"
requires "nigui"
requires "eminim"
requires "uuids"
requires "stacks"
requires "weave"
requires "zippy"
requires "iup"

# Also requires the user shell to have scp and ssh commands
# (They can be obtained via OpenSSH in windows, or via the desired distribution on linux)
# and a properly configured password-less authentication to the remarkable tablet
# (Read the wiki on how to do this)