rm *.json
jsonnet -m . groups_4_x.jsonnet
dos2unix .\*.json
