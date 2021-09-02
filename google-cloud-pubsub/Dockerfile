FROM ruby:2.7

# Copy application files and install the bundle
WORKDIR /usr/src/app
COPY . .
RUN bundle install

CMD ["bundle", "exec", "ruby", "subscribe.rb", "ruby-issue-8415-topic-85f08310"]