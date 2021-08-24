#!/usr/bin/env ruby

# Cleanup
def shut_down subscription, subscriber
  if subscriber
    puts "Stopping subscriber: #{subscriber.subscription_name}"
    subscriber.stop
    puts "Waiting for subscriber: #{subscriber.subscription_name}"
    subscriber.wait!
  end
  if subscription
    puts "Deleting subscription: #{subscription.name}"
    subscription.delete
    puts "Deleted subscription: #{subscription.name}"
  end
end

$subscriber = nil

begin
  puts "subscribe.rb PID: #{Process.pid}"
  require "google/cloud/pubsub"
  require "securerandom"
  pubsub = Google::Cloud::PubSub.new
  topic_name = ARGV[0]
  puts "ARGV[0] topic_name: #{topic_name}"
  topic = pubsub.topic topic_name
  raise "Topic not found for ARGV[0]: #{topic_name}" unless topic
  subscription_name = "#{topic_name}-sub-#{SecureRandom.hex(4)}".downcase
  $subscription = topic.subscribe subscription_name
  puts "Created subscription: #{$subscription.name}"

  # From https://github.com/googleapis/google-cloud-ruby/issues/8415
  subscriber_options = {
    streams: 3,
    inventory: 1000,
    threads: {
      callback: 6,
      push: 3
    }
  }
  $subscriber = $subscription.listen **subscriber_options do |msg|
    sleep 3
    if rand(10) == 0 # Simulate a processing error rate of 10%
      msg.modify_ack_deadline! 10
      puts "MOD: #{msg.data}"
    else
      msg.acknowledge!
      puts "ack: #{msg.data}"
    end
  end

  $subscriber.start
  loop do
    sleep 5
    puts "stream_pool: #{$subscriber.stream_pool.inspect}"
  end
ensure
  shut_down $subscription, $subscriber
end

Signal.trap "INT" do
  shut_down $subscription, $subscriber
  exit
end

Signal.trap "TERM" do
  shut_down $subscription, $subscriber
  exit
end

