# nvidia-docker run --rm -it -p 8888:8888 --name tensorflow -v /media/corey/raid/projects:/projects coreindustries/tensorflow
# nvidia-docker run --rm -it -p 8888:8888 --name tensorflow -v /media/corey/raid/projects:/projects gcr.io/tensorflow/tensorflow:latest-gpu

# bash, 
# nvidia-docker run --rm -it -p 8888:8888 --name tensorflow -v /mnt/raid/projects:/projects gcr.io/tensorflow/tensorflow:latest-devel-gpu


# tensorboard and iPython 
nvidia-docker run --rm -it -p 8888:8888 -p 6006:6006 --name tensorflow -v /mnt/raid/projects:/projects gcr.io/tensorflow/tensorflow:latest-gpu