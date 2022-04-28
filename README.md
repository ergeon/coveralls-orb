# Coveralls Orb

[![CircleCI Build Status](https://circleci.com/gh/ergeon/coveralls-orb/tree/master.svg?style=shield&circle-token=cb0134d462154a47084714bb7a35fb41164178f5 "CircleCI Build Status")](https://circleci.com/gh/ergeon/coveralls-orb/tree/master) [![CircleCI Orb Version](https://badges.circleci.com/orbs/ergeon/coveralls-orb.svg)](https://circleci.com/orbs/registry/orb/ergeon/coveralls-orb) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/ergeon/coveralls-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

This is a simple Orb based on https://github.com/coverallsapp/orb that will submit your coverage data to Coveralls.io.

## Commands

* `coveralls/upload`

## Examples

Each example below should be placed into `circle.yml` or `.circleci/config.yml` file

```yaml
version: 2.1

orbs:
  coveralls: ergeon/coveralls-orb@x.y.z

jobs:
  build:
    docker:
      - image: circleci/node:10.0.0

    steps:
      - checkout

      - run:
          name: Install and Make
          command: 'npm install && make test-coverage'

      - coveralls/upload
```

## Dev Notes

* Validate:

```bash
circleci orb validate orb.yml
```

* Publish:

```bash
circleci orb publish orb.yml ergeon/coveralls-orb@x.y.z
```

## License

This project is licensed under the terms of the [MIT license](/LICENSE).
