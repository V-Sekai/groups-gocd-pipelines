rm *.json
bin/jsonnet -m . src/godot_4_x.jsonnet
dos2unix *