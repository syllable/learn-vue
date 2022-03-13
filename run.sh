#!/bin/sh

# -it => keep stdin open and allocate pseudo-tty
# --rm => used with -d: the container is removed when it exits or when the daemon exits, whichever happens first
# -d => detached mode
# -p <host>:<container> => port mapping
# --name => give container a name (can only be used on first start, then the container has to be deleted to reuse the name)

# podman run -it -p 8081:80 --name todo-v1 localhost/todo-v1
podman run -it -p 8081:80 localhost/todo-v1
