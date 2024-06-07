FROM nginx:latest


RUN apt update -y && export DEBIAN_FRONTEND=noninteractive && apt install -y \
    build-essential \
    vim \
    vim-scripts \
    tcsh \
    && rm -Rf /var/lib/apt/lists/*

