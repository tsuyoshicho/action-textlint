#!/bin/sh

cd "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

if [ ! -f "$(npm bin)/textlint" ]; then
  npm install
fi

$(npm bin)/textlint --version

if [ "${INPUT_REPORTER}" == 'github-pr-review' ]; then
  # Use jq and github-pr-review reporter to format result to include link to rule page.
  $(npm bin)/textlint -f compact "${INPUT_TEXTLINT_FLAGS:-'.'}" \
    | reviewdog -efm="%f:%l:%c: %m" -name="textlint" -reporter=github-pr-review -level="${INPUT_LEVEL}"
else
  # github-pr-check (GitHub Check API) doesn't support markdown annotation.
  $(npm bin)/textlint -f compact "${INPUT_TEXTLINT_FLAGS:-'.'}" \
    | reviewdog -efm="%f:%l:%c: %m" -name="textlint" -reporter=github-pr-check -level="${INPUT_LEVEL}"
fi
