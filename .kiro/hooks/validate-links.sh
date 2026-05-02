#!/bin/bash

# Link Validation Hook for Blog Posts
# Checks all URLs in markdown files and reports broken links

set -uo pipefail

TIMEOUT=10
MAX_RETRIES=1
CONTENT_DIR="${1:-content/posts}"
RESULTS_FILE=$(mktemp)
trap 'rm -f "$RESULTS_FILE"' EXIT

echo "🔗 Validating links in: $CONTENT_DIR"

check_url() {
    local url="$1"
    local file="$2"
    local line="$3"

    # Skip mailto, anchor-only, and localhost links
    if [[ "$url" =~ ^(mailto:|#|http://localhost) ]]; then
        return 0
    fi

    echo "checked" >> "$RESULTS_FILE"
    local status
    status=$(curl -o /dev/null -s -w "%{http_code}" --head --location \
        --max-time "$TIMEOUT" --retry "$MAX_RETRIES" \
        -A "Mozilla/5.0 (compatible; BlogLinkChecker/1.0)" \
        "$url" 2>/dev/null || echo "000")

    if [[ "$status" -ge 400 ]] || [[ "$status" == "000" ]]; then
        echo "❌ [$status] $url"
        echo "   └─ $file:$line"
        echo "failed" >> "$RESULTS_FILE"
    fi
}

# Find and check all URLs in markdown files
while IFS= read -r file; do
    grep -nEo '\]\(https?://[^)]+\)|https?://[^\s\)\]\"<>]+' "$file" | while IFS=: read -r line match; do
        # Clean the URL from markdown syntax
        url=$(echo "$match" | sed 's/^\](//' | sed 's/)$//' | sed 's/^](//')
        url=$(echo "$url" | sed 's/[.,;:!?]$//')
        check_url "$url" "$file" "$line"
    done
done < <(find "$CONTENT_DIR" -name "*.md" -type f)

CHECKED=$(grep -c "checked" "$RESULTS_FILE" 2>/dev/null || echo "0")
FAILED=$(grep -c "failed" "$RESULTS_FILE" 2>/dev/null || echo "0")

echo ""
echo "📊 Results: $CHECKED links checked, $FAILED broken"

if [ "$FAILED" -gt 0 ]; then
    echo "❌ Link validation failed!"
    exit 1
else
    echo "✅ All links are valid!"
    exit 0
fi
