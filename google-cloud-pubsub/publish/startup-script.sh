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

# Install Stackdriver logging agent
curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
bash install-logging-agent.sh

# Install dependencies
apt-get update && apt-get -y upgrade && apt-get install -y autoconf bison \
    build-essential git libssl-dev libyaml-dev libreadline6-dev zlib1g-dev \
    libncurses5-dev libffi-dev libgdbm3 libgdbm-dev supervisor

# Account to own server process
useradd -m -d /home/rubyapp rubyapp

# Install Ruby and Bundler
mkdir /home/rubyapp/.ruby
git clone https://github.com/rbenv/ruby-build.git /home/rubyapp/.ruby-build
/home/rubyapp/.ruby-build/bin/ruby-build 2.6.5 /home/rubyapp/.ruby

chown -R rubyapp:rubyapp /home/rubyapp

cat >/home/rubyapp/.profile << EOF
export PATH="/home/rubyapp/.ruby/bin:$PATH"
EOF

su -l rubyapp -c "gem install bundler"

# Fetch source code
git clone https://github.com/quartzmo/google-cloud-ruby.git /opt/app

# Set ownership to newly created account
chown -R rubyapp:rubyapp /opt/app

# Install ruby dependencies
su -l rubyapp -c "cd /opt/app/google-cloud-pubsub && git checkout pubsub-stream-deadlock-issue-8415 && bundle install"

# Configure supervisor to run the ruby app
cat >/etc/supervisor/conf.d/rubyapp.conf << EOF
[program:rubyapp]
directory=/opt/app/google-cloud-pubsub
command=bash -lc "bundle exec ruby publish.rb"
autostart=true
autorestart=true
user=rubyapp
environment=HOME="/home/rubyapp",USER="rubyapp"
stdout_logfile=syslog
stderr_logfile=syslog
EOF

supervisorctl reread
supervisorctl update

# Application should now be running under supervisor
