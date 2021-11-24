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

require "google/cloud/pubsub"
require "faker"

pubsub = Google::Cloud::PubSub.new
topic_name = ARGV[0]
topic = pubsub.topic topic_name
raise "Topic not found for ARGV[0]: #{topic_name}" unless topic

messages = []
80.times do |n|
  message = {}
  message['id'] = "#{Time.now.to_i}#{n}"
  message['content'] = Faker::Lorem.paragraph(sentence_count: 10)
  messages << message.to_json
end

msgs = topic.publish do |batch_publisher|
  messages.each do |message|
      batch_publisher.publish message
  end
end

puts "Published #{msgs.count} messages to topic: #{topic.name}"
