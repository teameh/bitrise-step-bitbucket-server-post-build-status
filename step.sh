#!/usr/bin/env bash

join_ws() { local IFS=; local s="${*/#/$1}"; echo "${s#"$1$1$1"}"; }
joinStrings() { local a=("${@:3}"); printf "%s" "$2${a[@]/#/$1}"; }

INVALID_INPUT=false
if [ -z "$bitbucket_server_domain" ]; then
  INVALID_INPUT=true
  echo "- Missing input field: bitbucket_server_domain"
fi

if [ -z "$bitbucket_server_username" ]; then
  INVALID_INPUT=true
  echo "- Missing input field: bitbucket_server_username"
fi

if [ -z "$bitbucket_server_password" ]; then
  INVALID_INPUT=true
  echo "- Missing input field: bitbucket_server_password"
fi

if [ -z "$git_clone_commit_hash" ]; then
  INVALID_INPUT=true
  echo "- Missing input field: git_clone_commit_hash"
fi

if [ -z "$app_title" ]; then
  INVALID_INPUT=true
  echo "- Missing input field: app_title"
fi

if [ -z "$build_number" ]; then
  INVALID_INPUT=true
  echo "- Missing input field: build_number"
fi

if [ -z "$build_url" ]; then
  INVALID_INPUT=true
  echo "- Missing input field: build_url"
fi

if [ -z "$triggered_workflow_id" ]; then
  INVALID_INPUT=true
  echo "- Missing input field: triggered_workflow_id"
fi

if [ -z "$build_status" ] && [ -z "$build_is_in_progress" ]; then
  INVALID_INPUT=true
  echo "- Missing input field: build_status OR build_status"
fi

if [ ! -z $build_status ]; then
  if [ "$build_status" == 0 ]; then
    BITBUCKET_BUILD_STATE="SUCCESSFUL"
  elif [ "$build_status" == 1 ]; then
    BITBUCKET_BUILD_STATE="FAILED"
  else
    echo "- Invalid build_status: ${build_status}";
    INVALID_INPUT=true
  fi
fi

if [ ! -z "$build_is_in_progress" ] && [ "$build_is_in_progress" == true ]; then
  BITBUCKET_BUILD_STATE="INPROGRESS"
fi

if [ -z "$BITBUCKET_BUILD_STATE" ]; then
  echo "- build_status is not set and build_is_in_progress is unset or not true";
  INVALID_INPUT=true
fi

if [ "$INVALID_INPUT" == true ]; then
  exit 1
fi

BITBUCKET_API_ENDPOINT="https://$bitbucket_server_domain/rest/build-status/1.0/commits/$git_clone_commit_hash"

echo "Post build status: $BITBUCKET_BUILD_STATE"
echo "API Endpoint: $BITBUCKET_API_ENDPOINT"

curl $BITBUCKET_API_ENDPOINT \
  -X POST \
  -i \
  -u $bitbucket_server_username:$bitbucket_server_password \
  -H 'Content-Type: application/json' \
  --data-binary \
      $'{
        "state": "'$BITBUCKET_BUILD_STATE'",
        "key": "Bitrise",
        "name": "Bitrise '$app_title' #'$build_number'",
        "url": "'$build_url'",
        "description": "workflow: '$triggered_workflow_id'"
       }' \
   --compressed
