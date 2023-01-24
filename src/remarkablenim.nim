import os
import cmd/interactive

# Call like remarkablenim interactive to enter interactive mode
# Call like remarkablenim gui to enter GUI mode (TODO)
echo paramCount()
if paramCount() == 1:
    if paramStr(1) == "interactive":
        launch_interactive()