rm *.json
jsonnet -m . godot_4_x.jsonnet
dos2unix .\*.json
