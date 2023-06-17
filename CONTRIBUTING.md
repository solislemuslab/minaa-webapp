# Contributing to the MiNAA Web App

The following guidelines are designed for contributors to the MiNAA Web App.

## Reporting Issues and Questions

For reporting a bug, a failed function or requesting a new feature, open an issue in GitHub's [issue tracker](https://github.com/solislemuslab/minaa-webapp/issues). First, seach through existing issues (open or closed) that might have the answer to your question.

When reporting a bug, it is most helpful to include:

- A quick background/summary
- Specific steps to reproduce, with sample code if you can
- The expected result
- The actual result
- Notes (i.e. why you think this might be happening, or things you tried that didn't work)

## Contributing Code

To make contributions to the MiNAA Web App, request your changes or contributions via a pull request against the `development` branch of the MiNAA Web App repository.

Please use the following steps:

1. Fork the MiNAA Web App repository to your GitHub account.
2. Clone your fork locally with `git clone`.
3. Create a new branch with a name that describes your contribution. For example, if your contribution is a bug fix in the visualization tab, your new branch can be named `bugfix/vis-tab`. You can create and switch to it with `git checkout -b bugfix/vis-tab`
4. Make your changes on this new branch.
5. Push your changes to your fork.
6. [Submit a pull request](https://github.com/solislemuslab/minaa-webapp/pulls) against the `development` branch in the MiNAA Web App.

### Additional Setup

This web app serves as a wrapper around the the core MiNAA program, so for full functionality, it is necessary to include that executable in this program.

1. Clone and compile [MiNAA](https://github.com/solislemuslab/minaa). Further directions on this are provided in MiNAA's README.
2. Copy the resulting `minaa.exe` into the root directory of this project.
3. If necessary, update the permissions on this file to make it executable.
  On Unix: `chmod 500 minaa.exe`.

## License

By contributing, you agree that your contributions will be licensed under its MIT License.
