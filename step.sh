#!/usr/bin/env bash

join_ws() { local IFS=; local s="${*/#/$1}"; echo "${s#"$1$1$1"}"; }
joinStrings() { local a=("${@:3}"); printf "%s" "$2${a[@]/#/$1}"; }

INVALID_INPUT=false
if [ -z "$domain" ]; then
  INVALID_INPUT=true
  echo "- Missing input field: domain"
fi

if [ -z "$username" ]; then
  INVALID_INPUT=true
  echo "- Missing input field: username"
fi

if [ -z "$password" ]; then
  INVALID_INPUT=true
  echo "- Missing input field: password"
fi

if [ -z "$git_clone_commit_hash" ]; then
  git_clone_commit_hash=`git rev-parse HEAD`

  echo "- Missing input field: git_clone_commit_hash, falling back to 'git rev-parse HEAD' ($git_clone_commit_hash)"

  if [ -z "$git_clone_commit_hash" ]; then
    echo "- Unable to get git commit from current directory or git_clone_commit_hash input field"
    INVALID_INPUT=true
  fi
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

if [ -n "$preset_status" ] && [ "$preset_status" != "AUTO" ]; then
  if [ "$preset_status" == "INPROGRESS" ] || [ "$preset_status" == "SUCCESSFUL" ] || [ "$preset_status" == "FAILED" ]; then
    BITBUCKET_BUILD_STATE=$preset_status
  else
    echo "- Invalid preset_status, must be one of [\"AUTO\", \"INPROGRESS\", \"SUCCESSFUL\", \"FAILED\"]"
    INVALID_INPUT=true
  fi
elif [ -z "$BITRISE_BUILD_STATUS" ]; then
  echo "- Missing env var: \$BITRISE_BUILD_STATUS"
  INVALID_INPUT=true
elif [ "$BITRISE_BUILD_STATUS" == "0" ]; then
  BITBUCKET_BUILD_STATE="SUCCESSFUL"
elif [ "$BITRISE_BUILD_STATUS" == "1" ]; then
  BITBUCKET_BUILD_STATE="FAILED"
else
  echo "- Invalid \$BITRISE_BUILD_STATUS. Should be \"0\" or \"1\", not '$BITRISE_BUILD_STATUS'"
  INVALID_INPUT=true
fi

if [ "$INVALID_INPUT" == true ]; then
  exit 1
fi

BITBUCKET_API_ENDPOINT="https://$domain/rest/build-status/1.0/commits/$git_clone_commit_hash"

echo "Post build status: $BITBUCKET_BUILD_STATE"
echo "API Endpoint: $BITBUCKET_API_ENDPOINT"

# Bitbucket is storing a build status per COMMIT_HASH && KEY.
#
# Updating the build status of an existing build from INPROGRESS to FAILED or SUCCESSFUL needs to have the SAME commit_hash AND key.
# Re-running a failed build with the same commit should also have the same key so the status is updated.
#
# Docs: https://developer.atlassian.com/server/bitbucket/how-tos/updating-build-status-for-commits/

curl $BITBUCKET_API_ENDPOINT \
  -X POST \
  -i \
  -u $username:$password \
  -H 'Content-Type: application/json' \
  --data-binary \
      $"{
        \"state\": \"$BITBUCKET_BUILD_STATE\",
        \"key\": \"Bitrise - Build $triggered_workflow_id\",
        \"name\": \"Bitrise $app_title ($triggered_workflow_id) #$build_number\",
        \"url\": \"$build_url\",
        \"description\": \"workflow: $triggered_workflow_id\"
       }" \
   --compressed
