# DDP
Docker Drupal Production Environment

This is intended to be used in the following fashion:

1. there should be a complete www on the docker host which is mounted (i.e. -v /exports/www:/var/www) # this might also be done by nfs or similar

2. MySQL is handled externally and should be configured as such in the above www directory
