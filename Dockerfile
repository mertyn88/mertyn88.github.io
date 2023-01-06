FROM debian:latest

RUN apt update
RUN apt -y install ruby-full build-essential zlib1g-dev git locales locales-all vim

# Set language korean
#RUN export LANG=ko_KR.UTF-8
#RUN export LC_ALL=ko_KR.UTF-8

#RUN echo 'LANG=ko_KR.UTF-8' >> /etc/profile
#RUN echo 'LC_ALL=ko_KR.UTF-8' >> /etc/profile

# Set ruby
RUN echo '# Install Ruby Gems to ~/gems' >> ~/.bashrc
RUN echo 'export GEM_HOME="$HOME/gems"' >> ~/.bashrc
RUN echo 'export PATH="$HOME/gems/bin:$PATH"' >> ~/.bashrc
# RUN source ~/.bashrc

# Set jekyll
RUN gem install jekyll -v 4.2
RUN gem install bundler

# Set git
RUN git clone https://github.com/mertyn88/mertyn88.github.io.git
RUN git checkout -t origin/webrick_16
# RUN cd mertyn88.github.io

# Set jekyll
# RUN jekyll build


# Make shell
RUN echo '#!/bin/sh' >> ./run.sh
RUN echo 'cd mertyn88.github.io' >> ./run.sh
RUN echo 'jekyll build' >> ./run.sh
RUN echo 'jekyll serve --host 0.0.0.0 --port 4000 --force_polling --drafts --livereload --trace' >> ./run.sh
RUN chmod -R 777 ./run.sh

# CMD ["jekyll", "serve", "--host", "0.0.0.0", "--port", "4000", "--force_polling", "--drafts", "--livereload", "--trace"]
CMD export LANG=ko_KR.UTF-8;export LC_ALL=ko_KR.UTF-8;./run.sh

# Run container
# docker run -it -p 4000:4000 debian /bin/bash
# docker run -d -p 4000:4000 mertyn88/portfolio


# Run command
# jekyll serve --host 0.0.0.0 --port 4000


# Build image
# docker build -t mertyn88/portfolio .
