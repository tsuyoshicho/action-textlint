#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ] ; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

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

# shellcheck disable=SC2086
npx textlint -f checkstyle "${INPUT_TEXTLINT_FLAGS}"    \
      | reviewdog -f=checkstyle                         \
        -name="${INPUT_TOOL_NAME}"                      \
        -reporter="${INPUT_REPORTER:-github-pr-review}" \
        -filter-mode="${INPUT_FILTER_MODE}"             \
        -fail-on-error="${INPUT_FAIL_ON_ERROR}"         \
        -level="${INPUT_LEVEL}"                         \
        ${INPUT_REVIEWDOG_FLAGS}

# github-pr-review only diff adding
if [ "${INPUT_REPORTER}" = "github-pr-review" ]; then
  # fix
  npx textlint --fix "${INPUT_TEXTLINT_FLAGS:-.}" || true

  TMPFILE=$(mktemp)
  git diff >"${TMPFILE}"

  # shellcheck disable=SC2086
  reviewdog                        \
    -f=diff                        \
    -f.diff.strip=1                \
    -name="${INPUT_TOOL_NAME}-fix" \
    -reporter="github-pr-review"   \
    -filter-mode="diff_context"    \
    -level="${INPUT_LEVEL}"        \
    ${INPUT_REVIEWDOG_FLAGS} < "${TMPFILE}"

  git restore . || true
  rm -f "${TMPFILE}"
fi

# EOF
