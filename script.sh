#!/bin/bash

# shellcheck disable=SC2086,SC2089,SC2090

cd "${GITHUB_WORKSPACE}" || exit

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

PACKAGE_EXECUTER=npx

echo '::group:: Installing textlint ...  https://github.com/textlint/textlint'
if [ -x "./node_modules/.bin/textlint"  ]; then
  echo 'already installed'
elif [[ "${INPUT_PACKAGE_MANAGER}" == "npm" ]]; then
  echo 'npm ci start'
  npm ci
elif [[ "${INPUT_PACKAGE_MANAGER}" == "yarn" ]]; then
  echo 'yarn install start'
  yarn install
elif [[ "${INPUT_PACKAGE_MANAGER}" == "pnpm" ]]; then
  echo 'pnpm install start'
  pnpm install
elif [[ "${INPUT_PACKAGE_MANAGER}" == "bun" ]]; then
  echo 'bun install start'
  bun install
  PACKAGE_EXECUTER=bunx
else
  echo 'The specified package manager is not supported.'
  echo '::endgroup::'
  exit 1
fi

if [ -x "./node_modules/.bin/textlint"  ]; then
  $PACKAGE_EXECUTER textlint --version
else
  echo 'This repository was not configured for textlint, process done.'
  exit 1
fi
echo '::endgroup::'

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"


echo '::group:: Running textlint with reviewdog 🐶 ...'
textlint_exit_val="0"
reviewdog_exit_val="0"
# ignore preview exit code
reviewdog_exit_val2="0"

fail_level="${INPUT_FAIL_LEVEL}"
if [[ "${INPUT_FAIL_LEVEL}" == "none" ]] && [[ "${INPUT_FAIL_ON_ERROR}" == "true" ]]; then
  fail_level="error"
fi

echo "report level is: ${INPUT_LEVEL}"
echo "fail level is: ${fail_level}"

# shellcheck disable=SC2086
textlint_check_output=$(${PACKAGE_EXECUTER} textlint -f checkstyle ${INPUT_TEXTLINT_FLAGS} 2>&1) \
                      || textlint_exit_val="$?"

# shellcheck disable=SC2086
echo "${textlint_check_output}" | reviewdog -f=checkstyle \
        -name="${INPUT_TOOL_NAME}"                        \
        -reporter="${INPUT_REPORTER:-github-pr-review}"   \
        -filter-mode="${INPUT_FILTER_MODE}"               \
        -fail-level="${fail_level}"                       \
        -level="${INPUT_LEVEL}"                           \
        ${INPUT_REVIEWDOG_FLAGS} || reviewdog_exit_val="$?"
echo '::endgroup::'

# github-pr-review only diff adding
if [[ "${INPUT_REPORTER}" == "github-pr-review" ]]; then
  echo '::group:: Running textlint fixing report 🐶 ...'
  # fix
  $PACKAGE_EXECUTER textlint --fix ${INPUT_TEXTLINT_FLAGS:-.} || true

  TMPFILE=$(mktemp)
  git diff > "${TMPFILE}"

  git stash -u

  # shellcheck disable=SC2086,SC2034
  reviewdog                                 \
    -f=diff                                 \
    -f.diff.strip=1                         \
    -name="${INPUT_TOOL_NAME}-fix"          \
    -reporter="github-pr-review"            \
    -filter-mode="${INPUT_FILTER_MODE}"     \
    -fail-level="${fail_level}"             \
    -level="${INPUT_LEVEL}"                 \
    ${INPUT_REVIEWDOG_FLAGS} < "${TMPFILE}" \
    || reviewdog_exit_val2="$?"

  git stash drop || true
  echo '::endgroup::'
fi

# Throw error if an error occurred
# textlint exitcode: 0 success 1 lint error detect 2 fatal error
if [[ "${textlint_exit_val}" == "2" ]] || [[ "${reviewdog_exit_val}" != "0" ]]; then
  exit 1
fi

# EOF
