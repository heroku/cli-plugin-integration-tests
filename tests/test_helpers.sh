#!/bin/bash

assert_exists() {
  if [ ! -f "$1" ]; then
    echo "FAILED: Expected $1 to exist."
    exit 1
  fi
}

assert_contains() {
  local expected="${1}"
  local actual="${2}"
  local return_instead_of_exit="${3}"
  if echo "$actual" | grep -qi "$expected"; then
    :
  else
    echo "\nFAILED: expected ${expected} to match ${actual}"
    if [ "$return_instead_of_exit" == true ]; then
      return 1
    else
      exit 1
    fi
  fi
}

cleanup() {
  local app="${1}"
  local extra_pid="${2}"
  echo ''
  echo 'Cleaning up...'
  heroku destroy ${app} --confirm ${app}
  cd ../..
  rm -rf tmp/${app}

  if [ "$CI" != "true" ]; then
    pgid=$(ps -o pgid= $$ | grep -o '[0-9]*$')
    echo "Killing processes in group $pgid..."
    kill -- -$pgid
  elif [ -n "$extra_pid" ]; then
    kill $extra_pid
  fi
}

wait_for() {
  local cmd="${1}"
  sleep 2
  attempts=0
  until $(${cmd}); do
    attempts=$((attempts+1))
    if [ $attempts -gt 10 ]; then
      echo "Too many attempts waiting for service!"
      exit 1
    fi
    sleep 2
  done
}
