FROM ruby:2.7

# Copy application files and install the bundle
COPY . /google-cloud-ruby
WORKDIR /google-cloud-ruby/google-cloud-pubsub
RUN gem install bundler
RUN bundle install

CMD ["bundle", "exec", "ruby", "subscribe.rb", "ruby-issue-8415-topic-85f08310"]