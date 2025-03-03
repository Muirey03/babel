#!/bin/bash

#==============================================================================#
#                                  SETUP                                       #
#==============================================================================#

# Start in scripts/integration-tests/ even if run from root directory
cd "$(dirname "$0")" || exit
root="$PWD"

source utils/local-registry.sh
source utils/cleanup.sh

# Echo every command being executed
set -x

# Clone prettier
git clone --depth=1 --single-branch --branch next https://github.com/prettier/prettier tmp/prettier
cd tmp/prettier || exit

# Update @babel/* dependencies
bump_deps="$root/utils/bump-babel-dependencies.js"
node "$bump_deps"

#==============================================================================#
#                                 ENVIRONMENT                                  #
#==============================================================================#
node -v
yarn --version

#==============================================================================#
#                                   TEST                                       #
#==============================================================================#

startLocalRegistry "$root"/verdaccio-config.yml
yarn install --no-immutable
yarn info

# Test typings for @babel/parser
yarn lint:typecheck

# https://github.com/babel/babel/pull/14892#issuecomment-1233180626
echo "export default () => () => {}" > src/main/create-print-pre-check-function.js

# Temporarily ignore tests, use `rm -f path/to/jsfmt.spec.js`
# https://github.com/babel/babel/pull/15400#issuecomment-1414539133
# Ignore this test until prettier update the snapshot
# because prettier has ignored UnexpectedReservedWord error
rm -f tests/format/flow-repo/async/await_parse.js
rm -f tests/format/misc/errors/js/explicit-resource-management/invalid-using-binding-await.js
# https://github.com/babel/babel/pull/15384
rm -f tests/format/misc/errors/typescript/modifiers/jsfmt.spec.js

yarn test "tests/format/(jsx?|misc|typescript|flow|flow-repo)/" --update-snapshot --runInBand

cleanup
