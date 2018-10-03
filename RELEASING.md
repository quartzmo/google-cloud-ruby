# Releasing Google Cloud Ruby Client

These instructions apply to every gem within the [Google Cloud Ruby
Client](https://github.com/googleapis/google-cloud-ruby) project.

## Releasing individual gems and meta-packages

The Google Cloud Ruby Client project uses [semantic
versioning](http://semver.org). Replace the `<version>` placeholder in the
examples below with the appropriate number, e.g. `0.1.0`. Replace the `<gem>`
placeholder with the appropriate full name of the gem, e.g.
`google-cloud-datastore`.

After all [pull
requests](https://github.com/googleapis/google-cloud-ruby/pulls) for a
release have been merged and all Kokoro and [Circle CI
builds](https://circleci.com/gh/googleapis/google-cloud-ruby) are
green, you may create a release as follows:

1. In root directory of the project, switch to the master branch, ensure that
   you have no changes, and pull from the [project
   repo](https://github.com/googleapis/google-cloud-ruby).

    ```sh
    $ git checkout master
    $ git status
    $ git pull <remote> master
    ```

1. Review the report of changes for all gems.

    ```sh
    $ bundle exec rake changes
    ```

1. Choose a gem to release based on the changes report from the previous step.
   If there are changes to
   [google-cloud-env](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-env),
   [google-cloud-core](https://github.com/googleapis/google-cloud-ruby/tree/master/google-cloud-core),
   and/or
   [stackdriver-core](https://github.com/googleapis/google-cloud-ruby/tree/master/stackdriver-core),
   be sure to release them first, in the order listed. Release
   [google-cloud](https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud)
   and
   [stackdriver](https://github.com/googleapis/google-cloud-ruby/blob/master/stackdriver)
   last, in case of dependency changes.

1. In root directory of the project, review the changes for the gem since its
   last release.

    ```sh
    $ bundle exec rake changes[<gem>]
    ```

1. Review the commits in the output from the previous step, making note of
   significant changes. (For examples of what a significant change is, browse
   the changes in the gem's `CHANGELOG.md`.)

1. In directory for the gem, run
   [`releasetool start`](https://github.com/googleapis/releasetool). Complete
   the steps to create a commit for the gem. When asked, "Are you ready to
   create your release PR?", respond "n" if you have more gems to release, or
   "Y" if this is the last gem you want to release.

    ```sh
    $ cd <gem>
    $ releasetool start
    ```

1. If your gem is new, amend the commit created by releasetool, ensuring that
   the gem has been added to the [top-level
   `Gemfile`](https://github.com/googleapis/google-cloud-ruby/blob/master/Gemfile).
   Follow the steps in [Adding a new gem to
   meta-packages](#adding-a-new-gem-to-meta-packages), below.

1. If the [semver](http://semver.org/) version change for your gem requires
   an increase in the requirement for your gem in
   `google-cloud/google-cloud.gemspec` and/or
   `stackdriver/stackdriver.gemspec`, amend the commit created by releasetool,
   replacing the old version requirement with your new requirement.
   Note that because of the use of the [pessimistic
   operator (`~>`)](https://robots.thoughtbot.com/rubys-pessimistic-operator),
   only certain version changes will require updating the requirement. Note
   also that the dependency requirements in the `google-cloud` and
   `stackdriver` gems must remain compatible so the two can co-exist in the
   same bundle.

1. If your gem is new, amend the commit created by releasetool, ensuring that a
   nav link and a main entry including code example have been added to the
   [top-level README](https://github.com/googleapis/google-cloud-ruby/blob/master/README.md).

1. Verify that your changes are complete, and that the version numbers all
   match.

    ```sh
    $ git show
    ```

1. Repeat steps 3 through 10 if you are releasing multiple gems.

1. If you updated `google-cloud/google-cloud.gemspec` for a version change to
   any gem, repeat steps 4 through 10 for the `google-cloud` gem.

1. If you updated `stackdriver/stackdriver.gemspec` for a version change to any
   gem, repeat steps 4 through 10 for the `stackdriver` gem.

1. Assign the pull request created by releasetool to yourself for merging.
   Request the appropriate reviewers.

1. After your pull request has passed all checks and been approved by reviewers,
   **Rebase and merge** it. This will trigger a build job on [Circle
   CI](https://circleci.com/gh/googleapis/google-cloud-ruby).

1. Wait until the [Circle CI
   build](https://circleci.com/gh/googleapis/google-cloud-ruby) has
   passed for the merge commit in master.

1. In root directory of the project, run
   [`releasetool tag`](https://github.com/googleapis/releasetool). Select the
   correct pull request, then select the commit for a gem. Complete the
   steps to create a tag and GitHub release for the gem.

    ```sh
    $ releasetool tag
    ```

1. Wait until the [Circle CI
   build](https://circleci.com/gh/googleapis/google-cloud-ruby) has
   passed for the tag.

1. Confirm that the new version is displayed on the [google-cloud-ruby gh-pages
   doc
   site](https://http://googleapis.github.io/google-cloud-ruby/docs/). Or, to
   save time when releasing many gems at once, check out the gh-pages branch and
   pull repeatedly to confirm that it has received the new docs.

   If the gh-pages branch has not been updated, inspect the Kokoro build logs to
   confirm that the rake `post` task succeeded.

1. Confirm that the gem for the new version is available on
   [RubyGems.org](https://rubygems.org/gems/google-cloud).

   If RubyGems.org has not been updated, inspect the Circle CI build logs to
   confirm that the rake `release` task succeeded.

1. Repeat steps 17 through 20 for each gem in your merge commit.

1. After the Circle CI master branch build has successfully completed, confirm
   that the [Kokoro master branch
   builds](https://github.com/googleapis/google-cloud-ruby/commits/master) are
   also green by looking for green checkmarks next to the timestamp for each
   commit.

High fives all around!

## Adding a new gem to meta-packages

There are extra steps required to add a new gem to the `google-cloud` and/or
`stackdriver` meta-package gems. These instructions are for the `google-cloud`
gem.

1. Add the gem to
   [`google-cloud/Gemfile`](https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud/Gemfile).
1. Add the gem to
   [`google-cloud/google-cloud.gemspec`](https://github.com/googleapis/google-cloud-ruby/blob/master/google-cloud/google-cloud.gemspec).
1. Add the gem to
   [`gcloud/Gemfile`](https://github.com/googleapis/google-cloud-ruby/blob/master/gcloud/Gemfile).
