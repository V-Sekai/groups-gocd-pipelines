rm -rf build
mkdir -p build
rm -rf .github/workflows/
mkdir -p .github/workflows/
bin/jsonnet -m build src/godot_4_x.jsonnet
dos2unix build/*
