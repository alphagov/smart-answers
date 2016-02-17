# Start with a base Ubuntu 14:04 image
FROM ubuntu:trusty

MAINTAINER Ikenna N. Okpala <ikenna.okpala@digital.cabinet-office.gov.uk>

# Set up user environment
ENV DEBIAN_FRONTEND noninteractive
RUN adduser --disabled-password --gecos "" nuser && echo "nuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV HOME /home/nuser
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.en
ENV LC_ALL en_US.UTF-8
ENV RUBY_RVM_VERSION 2.2.4
ENV NVM_INSTALL_VERSION 0.10.32
USER nuser

# Add all base dependencies
RUN sudo apt-get update -y
RUN sudo apt-get install -y build-essential
RUN sudo apt-get install -y language-pack-en-base
RUN sudo apt-get install -y vim curl
RUN sudo apt-get install -y libnotify-dev imagemagick libmagickwand-dev
RUN sudo apt-get install -y git-core
RUN sudo apt-get install -y man
RUN sudo apt-get install -y phantomjs
RUN sudo apt-get install -y libgmp-dev
RUN sudo apt-get install -y ruby-dev
RUN sudo apt-get install -y zlib1g-dev
RUN sudo apt-get install -y libxslt-dev
RUN sudo apt-get install -y libxml2-dev
RUN sudo apt-get install -y freetds-dev

# Install RVM and RUBY
RUN /bin/bash -l -c "gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3"
RUN /bin/bash -l -c "curl -L get.rvm.io | bash -s stable"
RUN /bin/bash -l -c "rvm install $RUBY_RVM_VERSION"
RUN /bin/bash -l -c "rvm alias create default $RUBY_RVM_VERSION"
RUN /bin/bash -l -c "rvm use --default $RUBY_RVM_VERSION"

# Install NVM and Node
RUN /bin/bash -l -c "curl https://raw.githubusercontent.com/creationix/nvm/v0.17.3/install.sh | bash"
RUN /bin/bash -l -c "echo 'source ~/.nvm/nvm.sh' >> ~/.profile"
ENV PATH $HOME/.nvm/bin:$PATH
RUN /bin/bash -l -c "nvm install v\$NVM_INSTALL_VERSION"
RUN /bin/bash -l -c "nvm alias default v\$NVM_INSTALL_VERSION"
RUN /bin/bash -l -c "npm install -g phantom"

# Add the application to the container (cwd)

WORKDIR /govuk-content-schemas
ADD ./ /govuk-content-schemas
VOLUME ["/govuk-content-schemas"]

WORKDIR /smart-answers
ADD ./ /smart-answers
VOLUME ["/smart-answers"]

# Create Gemset
RUN /bin/bash -l -c "rvm gemset create smart-answers"
RUN /bin/bash -l -c "rvm use $RUBY_RVM_VERSION@smart-answers --default"
RUN /bin/bash -l -c "rvm get stable --auto-dotfiles"

# Install the bundle
RUN /bin/bash -l -c "gem install bundler -v 1.10.6; bundle install"

EXPOSE 3000
EXPOSE 3010
EXPOSE 5000

# Setup the entrypoint
ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["/smart-answers/startup_docker.sh"]
