#!/bin/sh

cd "$GITHUB_WORKSPACE" || true

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# setup and check.
if [ -x "./node_modules/.bin/textlint"  ]; then
  # pass
  :
else
  npm ci
fi

if [ -x "./node_modules/.bin/textlint"  ]; then
  npx textlint --version
else
  echo This repository was not configured for textlint, process done.
  exit 1
fi

npx textlint -f checkstyle "${INPUT_TEXTLINT_FLAGS:-.}"            \
      | reviewdog -f=checkstyle -name="textlint"                   \
                  -reporter="${INPUT_REPORTER:-'github-pr-check'}" \
                  -level="${INPUT_LEVEL:-'error'}"

# github-pr-review only diff adding
if [ "${INPUT_REPORTER}" = "github-pr-review" ]; then
  # fix
  npx textlint --fix "${INPUT_TEXTLINT_FLAGS:-.}" || true

  TMPFILE=$(mktemp)
  git diff >"${TMPFILE}"

  reviewdog                          \
    -name="textlint-fix"             \
    -f=diff                          \
    -f.diff.strip=1                  \
    -reporter="github-pr-review"     \
    -filter-mode="diff_context"      \
    -level="${INPUT_LEVEL:-'error'}" \
    <"${TMPFILE}"

  git restore . || true
fi

# EOF
