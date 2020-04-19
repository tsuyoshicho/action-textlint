#!/bin/sh

cd "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

textlint --version

textlint -f checkstyle "${INPUT_TEXTLINT_FLAGS:-'.'}"          \
  | reviewdog -f=checkstyle -name="textlint"                   \
              -reporter="${INPUT_REPORTER:-'github-pr-check'}" \
              -level="${INPUT_LEVEL:-'error'}"
