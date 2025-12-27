#!/bin/bash

# Content Validation Hook for Blog Posts
# Validates frontmatter, co-authorship, and content structure

set -e

echo "🔍 Running content validation..."

# Function to validate frontmatter
validate_frontmatter() {
    local file="$1"
    echo "Validating frontmatter in: $file"
    
    # Check if file has frontmatter
    if ! head -n 1 "$file" | grep -q "^---$"; then
        echo "❌ Missing frontmatter in $file"
        return 1
    fi
    
    # Extract frontmatter
    local frontmatter=$(sed -n '/^---$/,/^---$/p' "$file" | head -n -1 | tail -n +2)
    
    # Required fields
    local required_fields=("title" "date" "author" "description" "tags" "categories")
    
    for field in "${required_fields[@]}"; do
        if ! echo "$frontmatter" | grep -q "^$field:"; then
            echo "❌ Missing required field '$field' in $file"
            return 1
        fi
    done
    
    # Check co-authorship
    if ! echo "$frontmatter" | grep -q "author.*Mladen Trampic.*Kiro"; then
        echo "❌ Missing proper co-authorship attribution in $file"
        echo "   Expected: 'Mladen Trampic & Kiro'"
        return 1
    fi
    
    # Check draft status
    if echo "$frontmatter" | grep -q "draft: true"; then
        echo "⚠️  Draft content detected in $file"
    fi
    
    echo "✅ Frontmatter validation passed for $file"
}

# Function to validate content structure
validate_content_structure() {
    local file="$1"
    echo "Validating content structure in: $file"
    
    # Check for proper heading hierarchy
    local h1_count=$(grep -c "^# " "$file" || true)
    if [ "$h1_count" -gt 0 ]; then
        echo "⚠️  H1 headings found in content (should use H2-H6 only)"
    fi
    
    # Check for code blocks without language specification
    local unspecified_code=$(grep -c '^```$' "$file" || true)
    if [ "$unspecified_code" -gt 0 ]; then
        echo "⚠️  Code blocks without language specification found"
    fi
    
    echo "✅ Content structure validation completed for $file"
}

# Function to validate Hugo build
validate_hugo_build() {
    echo "Validating Hugo build..."
    
    if command -v hugo &> /dev/null; then
        if hugo --quiet --minify --buildDrafts=false; then
            echo "✅ Hugo build successful"
        else
            echo "❌ Hugo build failed"
            return 1
        fi
    else
        echo "⚠️  Hugo not found, skipping build validation"
    fi
}

# Main validation logic
main() {
    local exit_code=0
    
    # Find all markdown files in content/posts
    if [ -d "content/posts" ]; then
        while IFS= read -r -d '' file; do
            if ! validate_frontmatter "$file"; then
                exit_code=1
            fi
            if ! validate_content_structure "$file"; then
                exit_code=1
            fi
        done < <(find content/posts -name "*.md" -type f -print0)
    fi
    
    # Validate Hugo build
    if ! validate_hugo_build; then
        exit_code=1
    fi
    
    if [ $exit_code -eq 0 ]; then
        echo "🎉 All validations passed!"
    else
        echo "❌ Validation failed. Please fix the issues above."
    fi
    
    return $exit_code
}

# Run main function
main "$@"
