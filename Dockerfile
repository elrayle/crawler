# Copyright (c) Microsoft Corporation and others. Licensed under the MIT license.
# SPDX-License-Identifier: MIT

FROM python:3.6-slim-buster AS python_builds
ENV APPDIR=/opt/service

ARG BUILD_NUMBER=0
ENV CRAWLER_BUILD_NUMBER=$BUILD_NUMBER

# Support tools
RUN apt-get update
RUN apt-get install -y --no-install-recommends --no-install-suggests \
  bzip2 build-essential cmake curl gcc git \
  libssl-dev libreadline-dev zlib1g zlib1g-dev \
  libxml2-dev libxslt1-dev libgomp1 libpopt0 xz-utils
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install node
RUN echo "******** Install node ********"
ENV NODE_VERSION=16.13.0
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

# # Install ruby
# RUN curl -L https://github.com/rbenv/ruby-build/archive/v20180822.tar.gz | tar -zxvf - -C /tmp/
# RUN cd /tmp/ruby-build-* && ./install.sh && cd /
# RUN ruby-build -v 2.5.1 /usr/local && rm -rfv /tmp/ruby-build-*
# RUN gem install bundler -v 2.3.26 --no-document


# Install scancode
# Requirements as per https://scancode-toolkit.readthedocs.io/en/latest/getting-started/install.html
RUN echo "******** Install scancode ********"
ARG SCANCODE_VERSION="30.1.0.p1.nv.a"
RUN pip3 install click
RUN pip3 install --upgrade pip setuptools wheel
RUN curl -Os https://raw.githubusercontent.com/elrayle/scancode-toolkit/v$SCANCODE_VERSION/requirements.txt
RUN pip3 install --constraint requirements.txt --verbose git+https://github.com/elrayle/scancode-toolkit.git@v$SCANCODE_VERSION
RUN rm requirements.txt
RUN scancode --reindex-licenses
ENV SCANCODE_HOME=/usr/local/bin

# # Install REUSE
# RUN echo "******** Install REUSE ********"
# RUN pip3 install setuptools
# RUN pip3 install reuse==1.0.0

# # Install Licensee
# # The latest version of nokogiri (1.13.1) and faraday (2.3.0) requires RubyGem 2.6.0 while
# # the current RubyGem is 2.5.1. However, after upgrading RubyGem to 3.1.2, licensee:9.12.0 starts
# # to have hard time to find license in LICENSE file, like component npm/npmjs/-/caniuse-lite/1.0.30001344.
# # So we pin to the previous version of nokogiri and faraday.
# RUN echo "******** Install Licensee ********"
# RUN gem install nokogiri:1.12.5 --no-document && \
#   gem install faraday:1.10.0 --no-document && \
#   gem install public_suffix:4.0.7 --no-document && \
#   gem install licensee:9.12.0 --no-document

# # Check versions of installs
# RUN python --version
# RUN node --version
# RUN npm --version
# RUN ruby --version
# RUN scancode --version
# RUN reuse --version
# RUN licensee version

# # Crawler config
# RUN echo "******** Configure the crawler and copy it to the working directory ********"
# ENV CRAWLER_DEADLETTER_PROVIDER=cd(azblob)
# ENV CRAWLER_NAME=cdcrawlerprod
# ENV CRAWLER_QUEUE_PREFIX=cdcrawlerprod
# ENV CRAWLER_QUEUE_PROVIDER=storageQueue
# ENV CRAWLER_STORE_PROVIDER=cdDispatch+cd(azblob)+azqueue
# ENV CRAWLER_WEBHOOK_URL=https://api.clearlydefined.io/webhook
# ENV CRAWLER_AZBLOB_CONTAINER_NAME=production

# RUN git config --global --add safe.directory '*'

# COPY package*.json /tmp/
# COPY patches /tmp/patches
# RUN cd /tmp && npm install --production
# RUN mkdir -p "${APPDIR}" && cp -a /tmp/node_modules "${APPDIR}"

# WORKDIR "${APPDIR}"
# COPY . "${APPDIR}"

# ENV PORT 5000
# EXPOSE 5000
# ENTRYPOINT ["node", "index.js"]
