import os

filepath = 'd:/Aplikasi/mathall/mathall/lib/presentation/custom_difficulty/screens/custom_difficulty_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

start_idx = -1
end_idx = -1
brace_count = 0
in_func = False

for i, line in enumerate(lines):
    if 'void _showEditPresetDialog(' in line:
        start_idx = i
        in_func = True
    
    if in_func:
        brace_count += line.count('{')
        brace_count -= line.count('}')
        if brace_count == 0 and i > start_idx:
            end_idx = i
            break

if start_idx != -1 and end_idx != -1:
    print(f"Removing lines {start_idx} to {end_idx}")
    del lines[start_idx:end_idx+1]
    
    # replace calls
    for i in range(len(lines)):
        lines[i] = lines[i].replace('_showEditPresetDialog', 'showEditPresetDialog')

    import_str = "import 'package:mathall/presentation/custom_difficulty/widgets/preset_edit_dialog.dart';\n"
    lines.insert(4, import_str)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(lines)
else:
    print("Function not found!")
