ARG ruby_version=2.7.6
ARG base_image=ruby:$ruby_version-slim-buster

FROM $base_image AS builder

# TODO: remove these once they're set in the base image.
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=1
ENV NODE_ENV=production
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_PATH=$GEM_HOME
ENV BUNDLE_BIN=$GEM_HOME/bin
ENV PATH=$BUNDLE_BIN/bin:$PATH
ENV BUNDLE_WITHOUT="development test webkit"

# TODO: set these in the builder image.
ENV BUNDLE_IGNORE_MESSAGES=1
ENV BUNDLE_SILENCE_ROOT_WARNING=1
ENV BUNDLE_JOBS=12
ENV MAKEFLAGS=-j12

ENV GOVUK_APP_DOMAIN=unused
ENV GOVUK_WEBSITE_ROOT=unused


# TODO: have an up-to-date builder image and stop running apt-get upgrade.
# TODO: have a separate builder image which already contains the build-only deps.
RUN apt-get update -qy && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-suggests --no-install-recommends \
        build-essential nodejs npm && \
    apt-get clean
RUN npm install --global yarn

RUN mkdir -p /app && ln -fs /tmp /app/tmp && ln -fs /tmp /home/app
WORKDIR /app
COPY Gemfile Gemfile.lock .ruby-version /app/
RUN echo 'install: --no-document' >> /etc/gemrc && bundle install
COPY . /app
RUN bundle exec rails assets:precompile && rm -fr /app/log


FROM $base_image

# TODO: set these in the base image.
ENV RAILS_ENV=production
ENV RAILS_LOG_TO_STDOUT=1
ENV NODE_ENV=production
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_PATH=$GEM_HOME
ENV BUNDLE_BIN=$GEM_HOME/bin
ENV PATH=$GEM_HOME/bin:$PATH
ENV BUNDLE_WITHOUT="development test webkit"

ENV GOVUK_APP_NAME=smartanswers
ENV GOVUK_PROMETHEUS_EXPORTER=true

# TODO: have an up-to-date base image and stop running apt-get here.
RUN apt-get update -qy && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -fr /var/lib/apt/lists

RUN mkdir -p /app && ln -fs /tmp /app/tmp && ln -fs /tmp /home/app
RUN echo 'IRB.conf[:HISTORY_FILE] = "/tmp/irb_history"' > irb.rc
WORKDIR /app

COPY --from=builder /usr/bin/node* /usr/bin/
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app ./

RUN groupadd -g 1001 app && \
    useradd -u 1001 -g app app
USER 1001
CMD bundle exec puma
