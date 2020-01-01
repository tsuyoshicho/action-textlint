#!/bin/sh

cd "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

if [ ! -f "$(npm bin)/textlint" ]; then
  npm install
fi

$(npm bin)/textlint --version

$(npm bin)/textlint -f checkstyle "${INPUT_TEXTLINT_FLAGS:-'.'}"    \
  | reviewdog -f=checkstyle -name="textlint" -diff="git diff HEAD^" \
              -reporter="${INPUT_REPORTER:-'github-pr-check'}"      \
              -level="${INPUT_LEVEL:-'error'}"
