# backhub

> A simple shell script to back up GitHub repos, gists, stars and followings

Eventually I will probably work on this and make it a bit more user friendly
but at the moment it is at least functional for its main purpose which is
for me to call it automatically from my main backup script.

Note - I named and refer to it as `backhub`, but the script is named
`backhub.sh` so that GitHub will do its syntax highlighting.

---

# Usage

`cd` into an empty directory to use for the backup.
This script will generate some directories and files
without asking first and could overwrite data if you
run it somewhere unsafe. It will prompt and remind you
to be in a clean directory before beginning to run.

The command has the following syntax:

    backhub <repos|gists|starred|following>

The user whose data will be downloaded is determined as, respectively:

- The variable `$GITUSER` as passed directly to the function.
- The environment variable `$GITUSER`
- The username returned by `git config --global user.name`

To manually set a username, call the script according to this example:

    GITUSER="joe-schmo" backhub starred

Once you call it, it will take the given action, and
request all the data on it from the GitHub API. It's
a simple public API (note - no support for private repos),
so no API key is required. It will write files in the
following format:

- **repos**: each repository will be in a directory named whatever `git clone` wants to name it, usually the same name as the repository. For example, joe-schmo/boring-project will be in `./boring-project/`.

- **gists**: similar to *repos*, except the directory name will be the gist ID number.

- **starred**: A series of files - one for each "page" of 100 items. They are named, for example, `github-starred-3.json`, where the number 3 is the page number.

- **following**: similar to *starred*, except instead of `github-starred`, the filename prefix will be `github-following`.
