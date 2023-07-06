FROM ruby:3.1.2

RUN apt-get update -qq \
  && apt-get install -y nodejs

ADD . /sarahs-store-docker
WORKDIR /sarahs-store-docker

RUN bundle install

EXPOSE 3000

CMD ["bash"]

