# ROS Indigo PR2 docker image with PyRIDE built-in

### How to build the docker images

- run `docker build -t docker-ros-indigo-pr2 .`

### How to use the image

- run `docker run --rm -it -p 11311:11311 -p 9090:9090 docker-ros-indigo-pr2`

- run ros apps in the main shell

- attach a new shell with `docker exec -it bash -l`
