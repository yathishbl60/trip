# Contributing to Trip

Use this guide for your first contribution and each pull request. Contributions
can be documentation, translation review, reproducible bug reports, or code.

## Choose a small first change

- Correct a broken setup step or unclear guide.
- Review a `needs_review` translation in a language you know; see [Localization](docs/Localization.md).
- Improve a local preview for an existing empty, long-content, or accessibility state.
- Fix a reproducible issue within one owner, or improve the portable contributor tools.

Search existing issues and pull requests before starting. Small corrections can go
directly into a PR. For a new feature or a change to navigation, persistence, or
package contracts, open an issue to agree on the user benefit and scope first.
[Feature planning](docs/FeatureRoadmap.md) helps evaluate proposals; it does not
approve them.

Use the repository's bug, feature, or documentation issue form. Keep personal travel
data out of examples. Logical owners in the tooling identify source boundaries;
they do not assign human reviewers.

## Local setup

Fork the repository, clone your fork, and create a branch for your change. Run all
commands from the repository root. Documentation-only work does not require Xcode.
Native source checks and app work require macOS and a full Xcode installation.

1. Install **Python 3.12** (minimum 3.10). macOS's default `python3` may be too old.
   The scripts have no third-party Python dependencies. An optional local environment
   makes the interpreter used by shell scripts explicit:

   ```sh
   python3.12 -m venv .venv
   . .venv/bin/activate
   python3 --version
   ```

2. For native work, select an Xcode installation with iOS, visionOS, and macOS
   **27.3+ SDKs**. Adjust this example to your installed Xcode:

   ```sh
   export DEVELOPER_DIR="/Applications/Xcode-beta.app/Contents/Developer"
   python3 scripts/workspace.py doctor --require-ready --json
   ```

   Scripts respect `DEVELOPER_DIR` without changing global `xcode-select`. An older
   selected Xcode is not automatically replaced by a newer one. The doctor checks
   tools and SDK minimums; it does not compile or establish simulator availability.
   Running TripKit tests also requires a host macOS meeting its 27.3 minimum.

3. Establish the source baseline:

   ```sh
   bash scripts/check.sh
   ```

   Without Xcode or a Mac, use the [portable checks](docs/Testing.md#source-checks)
   and say which full checks you could not run. Keep baseline failures separate
   from failures introduced by your change.

Open `trip.xcodeproj` and select the shared `trip` scheme for app development.
Local packages resolve from `Packages/TripKit`; no remote registry is required.
Unsigned compilation needs no development team. To run the app, configure signing,
bundle identifiers, App Groups, and capabilities using
[Signed run setup](SYSTEM-INTEGRATIONS.md#signed-run-setup). Use disposable simulator data for
experiments; do not replace a valued signed installation with unsigned build output.

## Find the owner and make the change

Read [AGENTS.md](AGENTS.md), then find the smallest owning area:

```sh
python3 scripts/workspace.py list
python3 scripts/workspace.py locate trip/Features/Trips --json
python3 scripts/workspace.py context Trips --json
python3 scripts/workspace.py impact trip/Features/Trips --json
```

The context command gives source entry points, contracts, consumers, and relevant
guides. Read only what your change crosses. Follow the existing view → struct
controller → model flow, inject services, and use local preview fixtures. Keep Swift
files within 100 lines and members within 20 lines, subject to the documented
exception. Preserve unrelated edits and working user flows.

A small fix needs a clear PR description. Use the [task template](templates/task.md)
for a substantial feature or cross-owner change, and the [decision template](templates/decision.md)
when changing a lasting architectural contract. Update the owning guide and
manifests alongside changed boundaries. Follow [Development](docs/Development.md)
for scaffolding, parallel work, and AI-assisted changes.

Personal global AI skills are optional. If unavailable, use repository contracts
and current SDK documentation; do not copy personal skills into the repository.

## Check and submit

Select checks using [Testing](docs/Testing.md). Agent-run builds and benchmarks
require the user's request; additional executable or runtime work stays within
the agreed scope. Report any check you could not perform.

In the PR, explain the problem, resulting behavior, and material contract or
compatibility changes. List exact checks and their configuration. Separate source
checks, compilation, executable tests, and visual/device review. For UI changes,
include the states and layouts reviewed. Keep commits focused and exclude build
output, personal signing state, secrets, and private data.

For native CI configuration, follow [Automation](docs/Development.md#automation).
Make contributions under the repository's [MIT License](LICENSE). Maintainers
review and merge changes; an issue or draft PR does not approve a proposed feature.
