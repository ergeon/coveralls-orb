#!/bin/bash
if [ "$PARALLEL_FINISHED" = true ]; then
  echo "Parallel finished: ${PARALLEL_FINISHED}"
  curl "${COVERALLS_ENDPOINT}/webhook?repo_token=${COVERALLS_REPO_TOKEN}" \
    -d "payload[build_num]=$CIRCLE_WORKFLOW_ID&payload[status]=done"
  exit 0
fi

if [[ $EUID == 0 ]]; then export SUDO=""; else export SUDO="sudo"; fi

if [ ! -r "$PATH_TO_LCOV" ]; then
  pip install coveralls
else
  $SUDO npm install -g coveralls
fi
echo "coveralls installed"

if ! command -v python &> /dev/null; then
  $SUDO apt update
  $SUDO apt -y upgrade
  $SUDO apt install -y python
  python -c 'print("Python installed!")'
fi

export COVERALLS_FLAG_NAME="${FLAG_NAME}"

if [ "$PARALLEL" = true ]; then
  export COVERALLS_PARALLEL=true
fi

if [ -n "$CIRCLE_PULL_REQUEST" ] || [ "${CIRCLE_BRANCH}" = "develop" ] || [ "${CIRCLE_BRANCH}" = "master" ]; then
  echo "Uploading coverage report to Coveralls..."
  if [ ! -r "$PATH_TO_LCOV" ]; then
    CI_PULL_REQUEST=$PULL_REQUEST_NUMBER coveralls -v
  else
    < "$PATH_TO_LCOV" CI_PULL_REQUEST=$CIRCLE_PULL_REQUEST coveralls
  fi
else
  for I in 1 2 3 4 5
  do
    PULL_REQUEST_NUMBER=$(curl -sb -H "Accept: application/json" -H "Authorization: Token $GITHUB_API_TOKEN" "https://api.github.com/repos/$ORG_NAME/$CIRCLE_PROJECT_REPONAME/commits/$CIRCLE_SHA1/pulls" | python -c 'import json,sys;data=json.load(sys.stdin);pr_number=data[0]["number"] if data and isinstance(data, list) else "";print(pr_number)')
    echo "Pull request number: $PULL_REQUEST_NUMBER"
    if [ -n "$PULL_REQUEST_NUMBER" ]; then
      if [ ! -r "$PATH_TO_LCOV" ]; then
        CI_PULL_REQUEST=$PULL_REQUEST_NUMBER coveralls -v
      else
        PULL_REQUEST_URL="https://github.com/ergeon/$CIRCLE_PROJECT_REPONAME/pull/$PULL_REQUEST_NUMBER"
        echo "$PULL_REQUEST_URL"
        < "$PATH_TO_LCOV" CI_PULL_REQUEST=$PULL_REQUEST_URL coveralls
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
