import os

filepath = 'd:/Aplikasi/mathall/mathall/lib/presentation/custom_difficulty/screens/custom_difficulty_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# delete 712 to 986
del lines[711:986]

# replace _showEditPresetDialog with showEditPresetDialog
for i in range(len(lines)):
    lines[i] = lines[i].replace('_showEditPresetDialog', 'showEditPresetDialog')

# add import at top
import_str = "import 'package:mathall/presentation/custom_difficulty/widgets/preset_edit_dialog.dart';\n"
lines.insert(4, import_str)

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
