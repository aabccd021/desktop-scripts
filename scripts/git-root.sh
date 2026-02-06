#!/usr/bin/env bash
# git-root: Print the root directory of the current git repository
#
# Outputs the absolute path to the top-level directory of the
# current git repository.

git rev-parse --show-toplevel
