[![Github Action (main)](https://github.com/cyber-dojo/nginx/actions/workflows/main.yml/badge.svg)](https://github.com/cyber-dojo/nginx/actions)

- A docker-containerized micro-service for [https://cyber-dojo.org](http://cyber-dojo.org).
- The front-end [Nginx](https://www.nginx.com/) image for a [cyber-dojo](http://cyber-dojo.org) web server.
- Demonstrates a [Kosli](https://www.kosli.com/) instrumented [GitHub CI workflow](https://app.kosli.com/cyber-dojo/flows/nginx-ci/trails/) 
  deploying, with Continuous Compliance, to its [staging](https://app.kosli.com/cyber-dojo/environments/aws-beta/snapshots/) AWS environment.
- Deployment to its [production](https://app.kosli.com/cyber-dojo/environments/aws-prod/snapshots/) AWS environment is via a separate [promotion workflow](https://github.com/cyber-dojo/aws-prod-co-promotion).
- Uses attestation patterns from https://www.kosli.com/blog/using-kosli-attest-in-github-action-workflows-some-tips/

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
