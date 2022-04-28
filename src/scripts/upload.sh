#!/bin/bash
if [ "$PARALLEL_FINISHED" ]; then
  curl "${COVERALLS_ENDPOINT}/webhook?repo_token=${TOKEN}" \
    -d "payload[build_num]=$CIRCLE_WORKFLOW_ID&payload[status]=done"
  exit 0
fi
if [[ $EUID == 0 ]]; then export SUDO=""; else export SUDO="sudo"; fi
$SUDO npm install -g coveralls
if [ ! "$COVERALLS_REPO_TOKEN" ]; then
  export COVERALLS_REPO_TOKEN=$TOKEN
fi
if [ "$PARALLEL" ]; then
  export COVERALLS_PARALLEL=true
fi
# check for lcov file presence:
if [ ! -r "$PATH_TO_LCOV" ]; then
  echo "Please specify a valid 'path_to_lcov' parameter."
  exit 1
fi

if [ -n "$CIRCLE_PULL_REQUEST" ] || [ "${CIRCLE_BRANCH}" = "develop" ] || [ "${CIRCLE_BRANCH}" = "master" ]; then
  echo "Uploading coverage report to Coveralls..."
  if [ "$VERBOSE" ]; then
    < "$PATH_TO_LCOV" coveralls --verbose
  else
    < "$PATH_TO_LCOV" coveralls
  fi
else
  for I in 1 2 3 4 5
  do
    PULL_REQUEST_NUMBER=$(curl -sb -H "Accept: application/json" -H "Authorization: Token $GITHUB_API_TOKEN" "https://api.github.com/repos/$ORG_NAME/$CIRCLE_PROJECT_REPONAME/commits/$CIRCLE_SHA1/pulls" | python -c 'import json,sys;data=json.load(sys.stdin);print(data[0]["number"]) if data and isinstance(data, list) else print()')
    if [ -n "$PULL_REQUEST_NUMBER" ]; then
      if [ "$VERBOSE" ]; then
        < "$PATH_TO_LCOV" CI_PULL_REQUEST=$PULL_REQUEST_NUMBER coveralls --verbose
      else
        < "$PATH_TO_LCOV" CI_PULL_REQUEST=$PULL_REQUEST_NUMBER coveralls
      fi
      break
    else
      if [[ $I == 5 ]]; then
        echo "Pull Request wasn't found for this commit."
        echo "Please re-run this build once Pull Request will be opened."
        exit 1
      fi
      echo "PR not found yet, trying again after a while."
      echo "Waiting for 60 seconds..."
      sleep 60
    fi
  done
fi
