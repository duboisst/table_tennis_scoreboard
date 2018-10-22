FROM ruby:2.5
LABEL maintainer="stephane.dubois@sanofi.com"

#
# Prerequisites
#

# proxy
ARG http_proxy
ARG https_proxy

# installs nodejs and build utils then clean apt cache
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev glade && \
    apt-get clean

#
# Configuration
#

RUN gem install gtk3

# project location within the container
ENV PROJECT_DIR="/score"
ENV PATH=${PROJECT_DIR}:${PATH} HOME=${PROJECT_DIR}

WORKDIR ${PROJECT_DIR}

# copy app sources
COPY . .

#
# Clean up
#
CMD ruby gtk-score.rb
