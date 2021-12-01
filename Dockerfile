FROM quay.io/evl.ms/fullstaq-ruby:3.0.3-jemalloc-bullseye-slim

ARG PROJECT_ROOT=/app
WORKDIR $PROJECT_ROOT

RUN apt-get update -q && apt-get install --autoremove --no-install-recommends -y \
    curl python3 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
RUN chmod a+rx /usr/local/bin/yt-dlp

COPY --from=mwader/static-ffmpeg:4.4.1 /ffmpeg /usr/local/bin/

RUN gem install bundler --no-document

RUN bundle config set --local without 'development test'

COPY Gemfile* ./

RUN bundle install

COPY . .

ENV PRODUCTION=1
ENV YDL_PATH=/usr/local/bin/yt-dlp

CMD ["./entrypoint.production.sh"]
