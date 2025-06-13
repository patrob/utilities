#!/bin/bash

# Script to batch create GitHub issues from a JSON file
# Usage: ./batch-create-issues.sh <repo> <issues.json>

# Check if correct number of arguments provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <repo> <issues.json>"
    echo "Example: $0 username/repository issues.json"
    exit 1
fi

REPO="$1"
ISSUE_FILE="$2"

# Validate that the JSON file exists
if [ ! -f "$ISSUE_FILE" ]; then
    echo "Error: File '$ISSUE_FILE' not found"
    exit 1
fi

# Validate that jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    exit 1
fi

# Validate that gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is required but not installed"
    exit 1
fi

# Validate JSON file format
if ! jq empty "$ISSUE_FILE" 2>/dev/null; then
    echo "Error: '$ISSUE_FILE' is not valid JSON"
    exit 1
fi

echo "Creating issues in repository: $REPO"
echo "Reading issues from: $ISSUE_FILE"
echo ""

# Process each issue in the JSON file
jq -c '.[]' "$ISSUE_FILE" | while read -r issue; do
  title=$(echo "$issue" | jq -r '.title')
  body=$(echo "$issue" | jq -r '.body')
  
  echo "Creating issue: $title"
  
  if gh issue create --repo "$REPO" --title "$title" --body "$body"; then
    echo "✓ Successfully created issue: $title"
  else
    echo "✗ Failed to create issue: $title"
  fi
  echo ""
done

echo "Batch issue creation completed."