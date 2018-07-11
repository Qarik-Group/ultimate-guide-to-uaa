# Upstream Issues

This book is a WIP, and whilst writing it various pull requests or issues were raised on upstream projects. To help track their status I'll try to track them all here:

## Example applications

The [ultimate-guide-to-uaa-examples](https://github.com/starkandwayne/ultimate-guide-to-uaa-examples) project documents its own set of upstream pull requests/branches. Once they are merged these applications will need to update their own dependencies.

## [realworld-examples.md](/realworld-examples/#bosh-cli)

* `bucc uaa` command is available in the next release of BUCC after v0.5.0, and will automatically install the `uaa` CLI [[bucc#136](https://github.com/starkandwayne/bucc/pull/136/files)] [[bucc#145](https://github.com/starkandwayne/bucc/pull/145)]
* `bosh env` shows "User admin" when actually authorized as "client admin" [[bosh-cli#451](https://github.com/cloudfoundry/bosh-cli/pull/451)]
* `bosh.admin` added to new BOSH/UAA users by default - need to update documentation to match [[bosh-deployment#270](https://github.com/cloudfoundry/bosh-deployment/issues/270)]

* BUCC's UAA home page will include link to Concourse CI  [[bucc#133](https://github.com/starkandwayne/bucc/pull/133)]