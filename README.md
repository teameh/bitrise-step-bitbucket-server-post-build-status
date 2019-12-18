# Bitbucket server post build status

Post build status to bitbucket server

See step.yml for inputs

### Basic example

Typically you want to notify bitbucket when a build is started and when a build has finished. You can do this by adding this step twice to the steps of your workflow:

```
  my-workflow:
    steps:
    
    - bitbucket-server-post-build-status:
        inputs:
        - bitbucket_server_username: "$BITBUCKET_SERVER_USERNAME"
        - bitbucket_server_password: "$BITBUCKET_SERVER_PASSWORD"
        - bitbucket_server_domain: "$BITBUCKET_SERVER_DOMAIN"
        - build_is_in_progress: true
    
    - other-steps..
    - ..for-this-workflow
    
    - bitbucket-server-post-build-status:
        inputs:
        - bitbucket_server_username: "$BITBUCKET_SERVER_USERNAME"
        - bitbucket_server_password: "$BITBUCKET_SERVER_PASSWORD"
        - bitbucket_server_domain: "$BITBUCKET_SERVER_DOMAIN"

```
