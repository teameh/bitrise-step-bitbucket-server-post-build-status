#!/usr/bin/env bash
set -ex

echo "BITRISE_BUILD_STATUS: $build_status"

case $build_status in
0) BITBUCKET_BUILD_STATE="INPROGRESS" ;; # Not finished
1) BITBUCKET_BUILD_STATE="SUCCESSFUL" ;; # Successful
2) BITBUCKET_BUILD_STATE="FAILED"     ;; # Failed
3) BITBUCKET_BUILD_STATE="FAILED"     ;; # Aborted with failure
4) BITBUCKET_BUILD_STATE="SUCCESSFUL" ;; # Aborted with success
esac

echo "BITBUCKET_BUILD_STATE: $BITBUCKET_BUILD_STATE"

echo "curl: https://$bitbucket_server_domain/rest/build-status/1.0/commits/$git_clone_commit_hash"

curl https://$bitbucket_server_domain/rest/build-status/1.0/commits/$git_clone_commit_hash \
  -X POST \
  -i \
  -v \
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
