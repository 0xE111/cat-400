#!/bin/sh
git describe --tags --abbrev=0 | xargs echo -n > c4/version.txt
