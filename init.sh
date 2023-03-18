#!/bin/bash

set -e

git clone https://github.com/markuskreusch/pitest.git
git clone https://github.com/markuskreusch/commons-lang.git

cd pitest
git checkout meta_mutants
mvn clean install
