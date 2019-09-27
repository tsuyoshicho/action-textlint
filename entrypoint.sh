#!/bin/sh

cd "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

if [ ! -f "$(npm bin)/textlint" ]; then
  npm install
fi

$(npm bin)/textlint --version

if [ "${INPUT_REPORTER}" == 'github-pr-review' ]; then
  $(npm bin)/textlint -f checkstyle "${INPUT_TEXTLINT_FLAGS:-'.'}" \
    | reviewdog -f=checkstyle -name="textlint" -diff="git diff HEAD^" -reporter=github-pr-review -level="${INPUT_LEVEL}"
else
  # github-pr-check (GitHub Check API) doesn't support markdown annotation.
  $(npm bin)/textlint -f checkstyle "${INPUT_TEXTLINT_FLAGS:-'.'}" \
    | reviewdog -f=checkstyle -name="textlint" -diff="git diff HEAD^" -reporter=github-pr-check  -level="${INPUT_LEVEL}"
fi
