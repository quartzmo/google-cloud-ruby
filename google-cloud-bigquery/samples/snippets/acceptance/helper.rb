# Copyright 2020 Google LLC
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

require "minitest/autorun"
require "minitest/focus"

# Configure JUnit XML test formatting for TestGrid build health and test failure tracking.
if ENV["CI"] || ENV["KOKORO_JOB_NAME"]
  begin
    require "fileutils"
    FileUtils.mkdir_p "tmp/reports"
    require "minitest/reporters"
    unless defined? SpongeReporter
      class SpongeReporter < Minitest::Reporters::JUnitReporter
        private
        # Override the default reporter filename format (TEST-minitest.xml) to write
        # directly to sponge_log.xml as required by Kokoro/Sponge telemetry collection.
        def filename_for suite
          File.join @reports_path, "sponge_log.xml"
        end
      end
    end
    Minitest::Reporters.use! [
      Minitest::Reporters::SpecReporter.new,
      SpongeReporter.new("tmp/reports", false, { single_file: true })
    ]
  rescue LoadError
    # Fallback if minitest-reporters is not installed in the bundle.
  end
end
require "securerandom"

$temp_datasets = []

def time_plus_random
  "#{Time.now.to_i}_#{SecureRandom.hex 4}"
end

def register_temp_datasets *datasets
  $temp_datasets += datasets
end

def create_temp_dataset
  bigquery = Google::Cloud::Bigquery.new
  dataset = bigquery.create_dataset "test_dataset_#{time_plus_random}"
  register_temp_datasets dataset
  dataset
end

def delete_temp_datasets
  $temp_datasets.each do |dataset|
    dataset.delete force: true
  end
end

Minitest.after_run do
  delete_temp_datasets
end
