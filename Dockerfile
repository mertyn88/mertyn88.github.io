FROM debian:latest

# Ruby, Git , Locale, Vim, SSH install
RUN apt update
RUN apt -y install ruby-full build-essential zlib1g-dev git locales locales-all vim net-tools openssh-server curl

# Set ssh
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
RUN echo 'ChallengeResponseAuthentication no' >> /etc/ssh/sshd_config
RUN echo 'UsePAM no' >> /etc/ssh/sshd_config
RUN echo "root:root" | chpasswd

# Set ruby path
RUN echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
RUN echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
RUN echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc

# Jekyll install
RUN gem install jekyll -v 4.2
RUN gem install bundler

# Git config
RUN git config --global user.email "mertyn88@gmail.com"
RUN git config --global user.name "mertyn88"

# Git clone
RUN git clone https://github.com/mertyn88/mertyn88.github.io.git

# Make shell
RUN echo '#!/bin/sh' >> ./run.sh
RUN echo 'service ssh start' >> ./run.sh
RUN echo 'cd mertyn88.github.io' >> ./run.sh
# RUN echo 'git checkout -t origin/webrick_16' >> ./run.sh
RUN echo 'jekyll build' >> ./run.sh
RUN echo 'jekyll serve --host 0.0.0.0 --port 4000 --force_polling --drafts --livereload --trace' >> ./run.sh
RUN chmod -R 777 ./run.sh

# Set language korean & shell
CMD export LANG=ko_KR.UTF-8;export LC_ALL=ko_KR.UTF-8;./run.sh

# Command list =======================

# Run container
# docker run -d -p 4000:4000 -p 422:22 --name portfolio mertyn88/portfolio

# Exec root
# docker exec -it $(docker ps -aqf 'name=portfolio') /bin/sh -c 'cd mertyn88.github.io;export LANG=ko_KR.UTF-8;eval $(grep ^$(id -un): /etc/passwd | cut -d : -f 7-)'

# Run command
# jekyll serve --host 0.0.0.0 --port 4000

# Build image
# docker build -t mertyn88/portfolio .

# SSH connect
# ssh root@127.0.0.1 -p 422