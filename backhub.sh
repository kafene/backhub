#!/usr/bin/env bash

set -e

# This isn't a very smart script and if you're doing work somewhere
# important it will start creating files and directories.
# for now, leave making and cd-ing into a clean directory as an
# exercise for the user.
read -p "Are you in a clean directory? [y/N] "
if [[ ! "$REPLY" =~ [yY] ]]; then
    exit 0;
fi;

# API URL
api="https://api.github.com"

# Usage info
usage="$(basename $0): <repos|gists|starred|following>"

# Username, could be set as GITUSER in .bashrc or what have you.
# otherwise it defaults to one from gitconfig.
# Can also do, e.g. `GITUSER=bob backhub gists`
user=${GITUSER:-$(git config --global user.name)};

if [ -z "$user" ]; then
    echo "Could not find GitHub username!"
    echo "You can set one manually by caling:"
    echo "    GITUSER=<username> $(basename $0) <type>"
    exit 1
fi

# Get the user's requested action
case "$1" in
    repos)
        type="repos"
        regex='(?<="git_url": ")[^"]+(?=")'
        ;;
    gists)
        type="gists"
        regex='(?<="git_pull_url": ")[^"]+(?=")'
        ;;
    starred)
        type="starred"
        regex=''
        ;;
    following)
        type="following"
        regex=''
        ;;
    *)
        echo "$usage"
        exit 1
esac

# page counter
page=0

# first case - simpler types, like starred and following
# have an empty regex and don't need to clone.
if [ -z "$regex" ]; then
    while
        let page++;
        wget -O "github-$type-$page.json" "$api/users/$user/$type?page=$page&per_page=100";
    do
        # not a perfect way of determining it's "done" but it seems to work -
        # check the filesize and if gh api is giving an almost empty file
        # (an empty json array) then stop pulling the next page.
        size=$(du "github-$type-$page.json" | cut -f 1)
        if [ "$size" -lt 10 ]; then
            # remove the last (empty) file.
            rm "github-$type-$page.json"
            break
        fi
    done
# second case - clone all user repos
else
    while
        let page++;
        wget -q -O - "$api/users/$user/$type?page=$page&per_page=100" \
            | grep -Po "$regex";
    do
        :;
    done \
    | \
    while read git_url; do
        git clone "$git_url"
    done
fi

exit 0;
