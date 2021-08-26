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

# Cleanup
def shut_down topic
  if topic
    puts "Deleting topic: #{topic.name}"
    topic.delete
    puts "Deleted topic: #{topic.name}"
  end
end

$topic = nil

begin
  puts "publish.rb PID: #{Process.pid}"
  require "google/cloud/pubsub"
  require "securerandom"
  pubsub = Google::Cloud::PubSub.new
  topic_name = "ruby-issue-8415-topic-#{SecureRandom.hex(4)}".downcase
  $topic = pubsub.create_topic topic_name
  puts "Created topic: #{$topic.name}"
  count = 0
  loop do
    count += 1
    $topic.publish count.to_s
    print "."
    sleep 0.1
  end

ensure
  shut_down $topic
end

Signal.trap "INT" do
  shut_down $topic
  exit
end

Signal.trap "TERM" do
  shut_down $topic
  exit
end