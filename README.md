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
        - username: "$BITBUCKET_SERVER_USERNAME"
        - password: "$BITBUCKET_SERVER_PASSWORD"
        - domain: "$BITBUCKET_SERVER_DOMAIN"
        - preset_status: INPROGRESS
    
    - other-steps..
    - ..for-this-workflow
    
    - bitbucket-server-post-build-status:
        inputs:
        - username: "$BITBUCKET_SERVER_USERNAME"
        - password: "$BITBUCKET_SERVER_PASSWORD"
        - domain: "$BITBUCKET_SERVER_DOMAIN"

```

Make sure you use a 'secret' variable for the password
