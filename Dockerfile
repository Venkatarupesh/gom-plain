FROM ruby:3.3.0-alpine
ARG RAILS_ROOT=/app
ARG PACKAGES="tzdata postgresql-client bash libcurl libxml2 libxslt"
ARG BUILD_PACKAGES="build-base curl-dev git imagemagick libjpeg-turbo libgomp"
ARG DEV_PACKAGES="postgresql-dev libpq-dev imagemagick-dev libwebp-dev freetype-dev libc-dev gcc libxml2-dev libxslt-dev"
ARG RUBY_PACKAGES="tzdata"
ENV LANG C.UTF-8
ENV RAILS_ENV development
ENV RAILS_LOG_TO_STDOUT true
RUN mkdir -p $RAILS_ROOT
WORKDIR $RAILS_ROOT
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $PACKAGES $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES
COPY Gemfile* $RAILS_ROOT/
RUN bundle install --jobs $(nproc) --retry 3
COPY . $RAILS_ROOT/
RUN chmod +x $RAILS_ROOT/docker-entrypoint.sh
EXPOSE 3000
ENTRYPOINT ["sh", "./docker-entrypoint.sh"]