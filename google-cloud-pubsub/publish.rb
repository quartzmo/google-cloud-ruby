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
require "google/cloud/logging"
require "securerandom"

$topic = nil

begin
  logging = Google::Cloud::Logging.new
  resource = logging.resource "global"
  log_name = "publish-rb-#{Process.pid}"

  pubsub = Google::Cloud::PubSub.new
  topic_name = "ruby-issue-8415-topic-#{SecureRandom.hex(4)}".downcase
  $topic = pubsub.create_topic topic_name
  entry = logging.entry payload: "[#{log_name}] Created topic: #{$topic.name}"
  logging.write_entries [entry], log_name: log_name, resource: resource

  count = 0
  loop do
    count += 1
    $topic.publish_async count.to_s
    if count % 100 == 0
      entry = logging.entry payload: "published: #{count}"
      logging.write_entries [entry], log_name: log_name, resource: resource
    end

    sleep 0.1
  end

ensure
  $topic.delete if $topic
end

Signal.trap "INT" do
  $topic.delete if $topic
  exit
end

Signal.trap "TERM" do
  $topic.delete if $topic
  exit
end