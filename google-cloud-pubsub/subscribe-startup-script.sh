# Copyright 2021 Google LLC All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Install git, ruby and bundler
apt-get update && apt-get -y upgrade && apt-get install -y git ruby-full
gem install bundler

# Fetch source code
git clone https://github.com/quartzmo/google-cloud-ruby.git

# Install ruby dependencies and run the app
cd google-cloud-ruby/google-cloud-pubsub
git checkout pubsub-stream-deadlock-issue-8415
bundle install
bundle exec ruby subscribe.rb ruby-issue-8415-topic-85f08310
