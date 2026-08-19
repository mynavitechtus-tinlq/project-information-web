#!/bin/bash
# check-imports.sh - Detect raw HTML usage where UI primitives exist
# Usage: bash .skills/ui-primitives/scripts/check-imports.sh

set -e

SRC_DIR="${1:-src}"
VIOLATIONS=0

# Patterns: raw HTML elements that should use primitives
# Format: "pattern|primitive|import_path"
CHECKS=(
  '<button[> \n]|Button|@/components/ui/button'
  '<input[> \n]|Input|@/components/ui/input'
  '<textarea[> \n]|Textarea|@/components/ui/textarea'
  '<select[> \n]|Select|@/components/ui/select'
  '<table[> \n]|Table|@/components/ui/table'
  '<dialog[> \n]|Dialog|@/components/ui/dialog'
  '<label[> \n]|Label|@/components/ui/label'
  '<progress[> \n]|Progress|@/components/ui/progress'
)

# Exclude UI primitive source files themselves
EXCLUDE_DIR="src/components/ui"

echo "Scanning $SRC_DIR for raw HTML usage where primitives exist..."
echo ""

for check in "${CHECKS[@]}"; do
  IFS='|' read -r pattern primitive import_path <<< "$check"

  # Find violations (exclude ui/ source files and node_modules)
  results=$(grep -Ern "$pattern" "$SRC_DIR" \
    --include="*.tsx" --include="*.jsx" \
    --exclude-dir="node_modules" \
    2>/dev/null | grep -v "src/components/ui/" || true)

  if [ -n "$results" ]; then
    echo "## $pattern → Use $primitive from $import_path"
    echo "$results"
    echo ""
    VIOLATIONS=$((VIOLATIONS + $(echo "$results" | wc -l)))
  fi
done

echo "---"
if [ "$VIOLATIONS" -gt 0 ]; then
  echo "Found $VIOLATIONS violation(s). Use UI primitives instead of raw HTML."
  exit 1
else
  echo "No violations found."
  exit 0
fi
