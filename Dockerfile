FROM ruby:3.2

USER root
RUN useradd -m app
RUN bundle config set --local path '/home/app/vendor/bundle'

USER app
WORKDIR /home/app
COPY --chown=app:app Gemfile Gemfile.lock /home/app/
RUN bundle install

COPY --chown=app:app . /home/app/

CMD bundle exec rackup
