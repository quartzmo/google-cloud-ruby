# Copyright 2015 Google Inc. All rights reserved.
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

require "helper"
require "json"
require "uri"

describe Gcloud::Bigquery::QueryJob, :mock_bigquery do
  let(:job) { Gcloud::Bigquery::Job.from_gapi query_job_gapi,
                                              bigquery.service }
  let(:job_id) { job.job_id }

  it "knows it is query job" do
    job.must_be_kind_of Gcloud::Bigquery::QueryJob
  end

  it "knows its destination table" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    mock.expect :get_table, destination_table_gapi, ["target_project_id", "target_dataset_id", "target_table_id"]

    destination = job.destination
    destination.must_be_kind_of Gcloud::Bigquery::Table
    destination.project_id.must_equal "target_project_id"
    destination.dataset_id.must_equal "target_dataset_id"
    destination.table_id.must_equal   "target_table_id"
    mock.verify
  end

  it "knows its attributes" do
    job.must_be :batch?
    job.wont_be :interactive?
    job.must_be :large_results?
    job.must_be :cache?
    job.must_be :flatten?
  end

  it "knows its statistics data" do
    job.wont_be :cache_hit?
    job.bytes_processed.must_equal 123456
  end

  it "knows its query config" do
    job.config.must_be_kind_of Google::Apis::BigqueryV2::JobConfiguration
    job.config.query.destination_table.table_id.must_equal "target_table_id"
    job.config.query.create_disposition.must_equal "CREATE_IF_NEEDED"
    job.config.query.priority.must_equal "BATCH"
  end

  def query_job_gapi
    gapi = random_job_gapi
    gapi.configuration = Google::Apis::BigqueryV2::JobConfiguration.new(
      query: Google::Apis::BigqueryV2::JobConfigurationQuery.new(
        query: "SELECT name, age, score, active FROM [users]",
        destination_table: table_reference_gapi(
          "target_project_id",
          "target_dataset_id",
          "target_table_id"
        ),
        create_disposition: "CREATE_IF_NEEDED",
        write_disposition: "WRITE_EMPTY",
        default_dataset: dataset_reference_gapi(project, "my_dataset"),
        priority: "BATCH",
        use_query_cache: true,
        allow_large_results: true,
        flatten_results: true
      )
    )
    gapi.statistics = Google::Apis::BigqueryV2::JobStatistics.new(
      query: Google::Apis::BigqueryV2::JobStatistics2.new(
        cache_hit: false,
        total_bytes_processed: 123456
      )
    )
    gapi
  end
end
