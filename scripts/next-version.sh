#!/usr/bin/env bash
# Decide the next semantic version from Conventional Commit messages.
#
# Usage:
#   git log --format='%B%x00' <last-tag>..HEAD | scripts/next-version.sh <current>
#
# Reads NUL-separated commit messages (subject + body) on stdin and prints the
# next version, or nothing when no commit warrants a release. The highest bump
# across all commits wins:
#
#   any `type!:` subject, or a `BREAKING CHANGE:` / `BREAKING-CHANGE:` footer
#   at the start of a line (case-sensitive)          -> major
#   feat                                              -> minor
#   fix, perf, revert                                 -> patch
#   anything else                                     -> no bump
#
# The type is read from the subject only: a squash log or a quote in the body
# must not trigger a release. `bump(version):` commits are skipped so the bot's
# own commits never feed back into the decision.
set -euo pipefail

current="${1:-}"
if [[ ! "$current" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
	echo "next-version: invalid current version '${current}' (expected X.Y.Z)" >&2
	exit 2
fi
major="${BASH_REMATCH[1]}"
minor="${BASH_REMATCH[2]}"
patch="${BASH_REMATCH[3]}"

# 0 = none, 1 = patch, 2 = minor, 3 = major
level_of() {
	local msg="$1"
	local subject="${msg%%$'\n'*}"

	if grep -qE '^bump\(version\):' <<<"$subject"; then
		echo 0
	elif grep -qiE '^[a-z]+(\([^)]*\))?!:' <<<"$subject"; then
		echo 3
	elif grep -qE '^BREAKING[ -]CHANGE:' <<<"$msg"; then
		echo 3
	elif grep -qiE '^feat(\([^)]*\))?:' <<<"$subject"; then
		echo 2
	elif grep -qiE '^(fix|perf|revert)(\([^)]*\))?:' <<<"$subject"; then
		echo 1
	else
		echo 0
	fi
}

highest=0
# `|| [[ -n ... ]]` keeps a final message that lacks the trailing NUL.
while IFS= read -r -d '' msg || [[ -n "$msg" ]]; do
	# git log output may start with a blank line between records.
	msg="${msg#"${msg%%[![:space:]]*}"}"
	[[ -z "$msg" ]] && continue
	level="$(level_of "$msg")"
	if ((level > highest)); then
		highest="$level"
	fi
done

case "$highest" in
3) echo "$((major + 1)).0.0" ;;
2) echo "${major}.$((minor + 1)).0" ;;
1) echo "${major}.${minor}.$((patch + 1))" ;;
*) ;;
esac
