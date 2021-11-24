#!/usr/bin/env ruby

# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$LOAD_PATH.unshift "lib"

require "google/cloud/pubsub"
require "securerandom"
require "faker"
require "logger"

module MyLogger
  LOGGER = Logger.new $stdout, level: Logger::DEBUG
  def logger
    LOGGER
  end
end

# Define a gRPC module-level logger method before grpc/logconfig.rb loads.
module GRPC
  extend MyLogger
end

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
  pubsub = Google::Cloud::PubSub.new
  topic_name = ARGV[0]
  topic = pubsub.topic topic_name
  raise "Topic not found for ARGV[0]: #{topic_name}" unless topic
  subscription_name = "#{topic_name}-sub-#{SecureRandom.hex(4)}".downcase
  $subscription = topic.subscribe subscription_name
  puts "Created subscription: #{$subscription.name} for topic: #{topic.name}"


  configuration = {
    deadline: 10,
    streams: 2,
    inventory: {
      max_outstanding_messages: 80,
      max_total_lease_duration: 20
    },
    threads: { callback: 8, push: 4 }
  }
  
  $subscriber = $subscription.listen **configuration do |received_message|
    # process message
    puts "Data: #{received_message.message.data}, published at #{received_message.message.published_at}"
    received_message.acknowledge!
  end
    
  # Handle exceptions from listener
  $subscriber.on_error do |exception|
    puts "Exception: #{exception.class} #{exception.message}"
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
