#!/bin/bash

set -e

source $(dirname $0)/test_helpers.sh

heroku plugins:install heroku-cli-deploy

echo "TEST: heroku help deploy"
out=$(heroku help deploy)
assert_contains "Deploy WAR and JAR files" "$out"
echo "-> SUCCESS"

app="heroku-cli-test-${RANDOM}"
echo "Creating Heroku test app ${app}..."
heroku create ${app}
trap "{ cleanup ${app}; }" EXIT

echo "TEST: heroku deploy:war"
war="/tmp/sample.war"
curl -o ${war} -sL https://github.com/heroku/heroku-cli-deploy/raw/master/test/fixtures/sample-war.war
assert_exists "${war}"
echo "-> deploying"
out=$(cd /tmp && heroku deploy:war ${war} -a ${app})
assert_contains "including: sample.war" "$out"
assert_contains "-----> Done" "$out"
echo "-> SUCCESS"
