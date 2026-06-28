#!/bin/bash

set -e

#############################################
# Configuration
#############################################
BRANCH="main"
MONTH="June"
YEAR="2026"

echo "========================================="
echo "Repository : $(pwd)"
echo "========================================="

# Verify this is a Git repository
git rev-parse --is-inside-work-tree >/dev/null || {
    echo "Not a Git repository."
    exit 1
}

echo
echo "Pulling latest changes..."
git pull origin "$BRANCH"

echo
echo "Renaming files..."

i=1

find . -maxdepth 1 -type f \
    ! -name "auto_rename_push.sh" \
    | sort -t'-' -k2,2n | while read file
do
    file=$(basename "$file")

    ext=""
    if [[ "$file" == *.* ]]; then
        ext=".${file##*.}"
    fi

    new_name=$(printf "Day%02d-%d-%s-%s%s" "$i" "$i" "$MONTH" "$YEAR" "$ext")

    if [ "$file" != "$new_name" ]; then
        echo "$file  -->  $new_name"
        git mv "$file" "$new_name"
    fi

    ((i++))
done

echo
echo "Adding changes..."
git add .

if git diff --cached --quiet; then
    echo "No changes to commit."
    exit 0
fi

echo
git status

echo
echo "Committing..."
git commit -m "Rename June timing files sequentially"

echo
echo "Pushing..."
git push origin "$BRANCH"

echo
echo "========================================="
echo "SUCCESS!"
echo "========================================="
