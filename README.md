# GitHub Action: Run textlint with reviewdog

## notice

action-textlint use textlint within npm ecosystem.

## detail

[![Release](https://github.com/tsuyoshicho/action-textlint/workflows/release/badge.svg)](https://github.com/tsuyoshicho/action-textlint/releases)

This action runs [textlint](https://github.com/textlint/textlint) with
[reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve
text review experience.

based on [reviewdog/action-vint](https://github.com/reviewdog/action-vint)

[![github-pr-check example](https://user-images.githubusercontent.com/96727/70858620-bdc2fb80-1f48-11ea-9c1a-b5abb5a6566a.png)](https://user-images.githubusercontent.com/96727/70858620-bdc2fb80-1f48-11ea-9c1a-b5abb5a6566a.png)
[![github-pr-review example](https://user-images.githubusercontent.com/96727/70858610-a1bf5a00-1f48-11ea-84c4-7ee7392548e6.png)](https://user-images.githubusercontent.com/96727/70858610-a1bf5a00-1f48-11ea-84c4-7ee7392548e6.png)

Notice:
This action is `composition action`. It need `npm ci`.

You accept below one:

- Your workflow manually setup to run `npm ci`.
- This action automatic run `npm ci`.

## Inputs

### `github_token`

**Required**. Default is `${{ github.token }}`.

### `level`

Optional. Report level for reviewdog [info,warning,error].
It's same as `-level` flag of reviewdog.

### `reporter`

Reporter of reviewdog command [github-pr-check,github-check,github-pr-review].
Default is github-pr-review.
It's same as `-reporter` flag of reviewdog.

github-pr-review can use Markdown and add a link to rule page in reviewdog reports.

### `filter_mode`

Optional. Filtering mode for the reviewdog command [added,diff_context,file,nofilter].
Default is added.

### `fail_level`

Optional.  Exit code control for reviewdog, [none,any,info,warning,error]
Default is `none`.

### `fail_on_error`

**Deprecated.**

Optional.  Exit code for reviewdog when errors are found [true,false]
Default is `false`.

If `true` is set, it will be interpreted as "-fail-level=error".
But if "-fail-level" is set non-`none`, it will be ignored.

### `reviewdog_flags`

Optional. Additional reviewdog flags

### `textlint_flags`

textlint arguments (i.e. target dir:`doc/*`)

### `package_manager`

Optional. Package manager used in the repository [npm,yarn,pnpm,bun]
Default is `npm`.

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
      - name: Checkout
        uses: actions/checkout@v2
        with:
          submodules: true
      - name: Setup node/npm
        uses: actions/setup-node@v1
        with:
          node-version: '15'
      - name: textlint-github-pr-check
        uses: tsuyoshicho/action-textlint@v3
        with:
          github_token: ${{ secrets.github_token }}
          reporter: github-pr-check
          textlint_flags: "doc/**"
      - name: textlint-github-check
        uses: tsuyoshicho/action-textlint@v3
        with:
          github_token: ${{ secrets.github_token }}
          reporter: github-check
          textlint_flags: "doc/**"
      - name: textlint-github-pr-review
        uses: tsuyoshicho/action-textlint@v3
        with:
          github_token: ${{ secrets.github_token }}
          reporter: github-pr-review
          textlint_flags: "doc/**"
```
