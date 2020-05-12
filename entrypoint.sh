#!/bin/sh

cd "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# nothing command, try project package install
if npm ls textlint 2&> /dev/null; then
  # pass
  :
else
  npm install
fi
# nothing command in after install, use command direct install
PACKAGE=""
if npm ls textlint 2&> /dev/null; then
  npx textlint --version
else
  PACKAGE="-p textlint@${INPUT_TEXTLINT_VERSION:-11.6.3}"
  echo textlint direct install version: ${INPUT_TEXTLINT_VERSION:-11.6.3}
fi

npx ${PACKAGE} textlint -f checkstyle "${INPUT_TEXTLINT_FLAGS:-.}" \
      | reviewdog -f=checkstyle -name="textlint"                   \
                  -reporter="${INPUT_REPORTER:-'github-pr-check'}" \
                  -level="${INPUT_LEVEL:-'error'}"

# EOF
