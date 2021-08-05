rm *.json
jsonnet -m . godot_3_x.jsonnet
jsonnet -m . groups_4_x.jsonnet
dos2unix .\*.json
