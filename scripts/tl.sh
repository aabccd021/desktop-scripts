#!/usr/bin/env bash
# tl: Quick translation to English, Japanese, and Indonesian
#
# Wrapper around translate-shell that translates input text to
# multiple target languages with minimal output formatting.

trans \
  -show-original n \
  -show-translation-phonetics n \
  -show-languages n \
  -join-sentence \
  -target en+ja+id \
  "$@"
