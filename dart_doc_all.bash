#!/bin/bash

# Check if lib directory exists
if [ ! -d "lib" ]; then
  echo "Error: 'lib' directory not found."
  exit 1
fi

# Create the export file with all exports
echo "// AUTO-GENERATED EXPORT FILE" > lib/fit_office.dart
find lib -name "*.dart" ! -name "main.dart" ! -name "fit_office.dart" | while read file; do
  echo "export '${file/lib\//}';" >> lib/fit_office.dart
done

# Generate documentation for the lib directory (not the specific file)
dart doc .

# Start the python server to serve the documentation
python -m http.server 8000 --directory doc/api &

# Notify the user
echo "Documentation generated and served at http://localhost:8000"

# Open the documentation in the default web browser
if command -v xdg-open > /dev/null; then
  xdg-open http://localhost:8000
elif command -v open > /dev/null; then
  open http://localhost:8000
else
  echo "Please open http://localhost:8000 in your web browser."
fi