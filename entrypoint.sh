#!/bin/sh

cd "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# setup and check.
npm ci
if npm ls textlint &> /dev/null; then
  :
  # pass
else
  echo This repository was not configured for textlint, process done.
  exit 1
fi

npx textlint -f checkstyle "${INPUT_TEXTLINT_FLAGS:-.}"            \
      | reviewdog -f=checkstyle -name="textlint"                   \
                  -reporter="${INPUT_REPORTER:-'github-pr-check'}" \
                  -level="${INPUT_LEVEL:-'error'}"

# EOF
