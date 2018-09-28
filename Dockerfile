FROM ruby:2.2

RUN gem install bundler

COPY ./Gemfile /app/Gemfile
COPY ./Gemfile.lock /app/Gemfile.lock
WORKDIR /app
RUN bundle install

COPY . /app

CMD puma
