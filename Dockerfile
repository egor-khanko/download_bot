FROM quay.io/evl.ms/fullstaq-ruby:3.0.3-jemalloc-bullseye-slim

ARG PROJECT_ROOT=/app
LABEL maintainer="vanopiano"
ENV PRODUCTION=1

RUN apt-get update -q && apt-get install --autoremove --no-install-recommends -y \
    curl python3 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/youtube-dl
RUN chmod a+rx /usr/local/bin/youtube-dl

COPY --from=mwader/static-ffmpeg:4.4.1 /ffmpeg /usr/local/bin/

WORKDIR $PROJECT_ROOT

RUN gem install bundler --no-document && \
    bundle config set --local without 'development test'

COPY Gemfile* ./
RUN bundle install

COPY . .

VOLUME ["/app/data"]

CMD ["./entrypoint.sh"]
