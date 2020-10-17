# GitHub Action: Run textlint with reviewdog

## IMPORTANT NOTICE

action-textlint use textlint within npm ecosystem.
___v1 series support npm less than v7___.
___IF use with npm v7 or later, please used v2 series___.

## detail

[![Docker Image CI](https://github.com/tsuyoshicho/action-textlint/workflows/Docker%20Image%20CI/badge.svg)](https://github.com/tsuyoshicho/action-textlint/actions)
[![Release](https://github.com/tsuyoshicho/action-textlint/workflows/release/badge.svg)](https://github.com/tsuyoshicho/action-textlint/releases)

This action runs [textlint](https://github.com/textlint/textlint) with
[reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve
text review experience.

based on [reviewdog/action-vint](https://github.com/reviewdog/action-vint)

[![github-pr-check example](https://user-images.githubusercontent.com/96727/70858620-bdc2fb80-1f48-11ea-9c1a-b5abb5a6566a.png)](https://user-images.githubusercontent.com/96727/70858620-bdc2fb80-1f48-11ea-9c1a-b5abb5a6566a.png)
[![github-pr-review example](https://user-images.githubusercontent.com/96727/70858610-a1bf5a00-1f48-11ea-84c4-7ee7392548e6.png)](https://user-images.githubusercontent.com/96727/70858610-a1bf5a00-1f48-11ea-84c4-7ee7392548e6.png)

## Inputs

### `github_token`

**Required**. Must be in form of `github_token: ${{ secrets.github_token }}`'.

### `level`

Optional. Report level for reviewdog [info,warning,error].
It's same as `-level` flag of reviewdog.

### `reporter`

Reporter of reviewdog command [github-pr-check,github-check,github-pr-review].
Default is github-pr-check.
It's same as `-reporter` flag of reviewdog.

github-pr-review can use Markdown and add a link to rule page in reviewdog reports.

### `textlint_flags`

textlint arguments (i.e. target dir:`doc/*`)

### `textlint_version`

if textlint do not contain in project, use this version.

## Customizes

`.textlintrc` put in your repo.
And need textlint included in project package.json .

## Example usage

### [.github/workflows/reviewdog.yml](.github/workflows/reviewdog.yml)

```yml
name: reviewdog
on: [pull_request]
jobs:
  textlint:
    name: runner / textlint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          submodules: true
      - name: textlint-github-pr-check
        uses: tsuyoshicho/action-textlint@v1
        with:
          github_token: ${{ secrets.github_token }}
          reporter: github-pr-check
          textlint_flags: "doc/**"
      - name: textlint-github-check
        uses: tsuyoshicho/action-textlint@v1
        with:
          github_token: ${{ secrets.github_token }}
          reporter: github-check
          textlint_flags: "doc/**"
      - name: textlint-github-pr-review
        uses: tsuyoshicho/action-textlint@v1
        with:
          github_token: ${{ secrets.github_token }}
          reporter: github-pr-review
          textlint_flags: "doc/**"
```
