rm *.json
bin/jsonnet -m . godot_3_x.jsonnet
bin/jsonnet -m . groups_4_x.jsonnet
dos2unix *