# Copyright 2016 Google Inc. All rights reserved.
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


require "gcloud/version"
require "google/apis/bigquery_v2"
require "pathname"
require "digest/md5"

module Gcloud
  module Bigquery
    ##
    # @private
    # Represents the service to BigQuery, exposing the API calls.
    class Service
      ##
      # Alias to the Google Client API module
      API = Google::Apis::BigqueryV2

      attr_accessor :project
      attr_accessor :credentials

      ##
      # Creates a new Service instance.
      def initialize project, credentials
        @project = project
        @credentials = credentials
        @service = API::BigqueryService.new
        @service.client_options.application_name    = "gcloud-ruby"
        @service.client_options.application_version = Gcloud::VERSION
        @service.authorization = @credentials.client
      end

      def service
        return mocked_service if mocked_service
        @service
      end
      attr_accessor :mocked_service

      ##
      # Lists all datasets in the specified project to which you have
      # been granted the READER dataset role.
      # Returns Google::Apis::BigqueryV2::DatasetList
      def list_datasets options = {}
        service.list_datasets @project, all: options.delete(:all),
                                        max_results: options.delete(:max),
                                        page_token: options.delete(:token)
      end

      ##
      # Returns Google::Apis::BigqueryV2::Dataset
      def get_dataset dataset_id
        service.get_dataset @project, dataset_id
      end

      ##
      # Creates a new empty dataset.
      def insert_dataset dataset_id, options = {}
        service.insert_dataset @project,
                               insert_dataset_request(dataset_id, options)
      end

      ##
      # Updates information in an existing dataset, only replacing
      # fields that are provided in the submitted dataset resource.
      def patch_dataset dataset_id, options = {}
        project_id = options[:project_id] || @project

        service.patch_dataset project_id,
                              dataset_id,
                              patch_dataset_request(options)
      end

      ##
      # Deletes the dataset specified by the dataset_id value.
      # Before you can delete a dataset, you must delete all its tables,
      # either manually or by specifying force: true in options.
      # Immediately after deletion, you can create another dataset with
      # the same name.
      def delete_dataset dataset_id, force = nil
        service.delete_dataset @project, dataset_id, delete_contents: force
      end

      ##
      # Lists all tables in the specified dataset.
      # Requires the READER dataset role.
      def list_tables dataset_id, options = {}
        service.list_tables @project,
                            dataset_id,
                            max_results: options.delete(:max),
                            page_token: options.delete(:token)
      end

      def get_project_table project_id, dataset_id, table_id
        service.get_table project_id, dataset_id, table_id
      end

      ##
      # Gets the specified table resource by table ID.
      # This method does not return the data in the table,
      # it only returns the table resource,
      # which describes the structure of this table.
      def get_table dataset_id, table_id
        get_project_table @project, dataset_id, table_id
      end

      ##
      # Creates a new, empty table in the dataset.
      def insert_table dataset_id, table_id, options = {}
        service.insert_table @project,
                             dataset_id,
                             insert_table_request(dataset_id, table_id, options)
      end

      ##
      # Updates information in an existing table, replacing fields that
      # are provided in the submitted table resource.
      def patch_table dataset_id, table_id, options = {}
        service.patch_table @project,
                            dataset_id,
                            table_id,
                            patch_table_request(options)
      end

      ##
      # Deletes the table specified by tableId from the dataset.
      # If the table contains data, all the data will be deleted.
      def delete_table dataset_id, table_id
        service.delete_table @project, dataset_id, table_id
      end

      ##
      # Retrieves data from the table.
      def list_tabledata dataset_id, table_id, options = {}
        service.list_table_data @project, dataset_id, table_id,
                                max_results: options.delete(:max),
                                page_token: options.delete(:token),
                                start_index: options.delete(:start)
      end

      def insert_tabledata dataset_id, table_id, rows, options = {}
        service.insert_all_table_data @project,
                                      dataset_id,
                                      table_id,
                                      insert_tabledata_rows(rows, options)
      end

      ##
      # Lists all jobs in the specified project to which you have
      # been granted the READER job role.
      def list_jobs options = {}
        service.list_jobs @project, all_users: options.delete(:all),
                                    max_results: options.delete(:max),
                                    page_token: options.delete(:token),
                                    projection: "full",
                                    state_filter: options.delete(:filter)
      end

      ##
      # Returns the job specified by jobID.
      def get_job job_id
        service.get_job @project, job_id
      end

      def insert_job config
        job_object = { configuration: config }
        service.insert_job @project, job_object
      end

      def query_job query, options = {}
        service.insert_job @project, query_table_config(query, options)
      end

      def query query, options = {}
        service.query_job @project, query_config(query, options)
      end

      ##
      # Returns the query data for the job
      def job_query_results job_id, options = {}
        service.get_job_query_results @project,
                                      job_id,
                                      max_results: options.delete(:max),
                                      page_token: options.delete(:token),
                                      start_index: options.delete(:start),
                                      timeout_ms: options.delete(:timeout)
      end

      def copy_table source, target, options = {}
        service.insert_job @project, copy_table_config(source, target, options)
      end

      def link_table table, urls, options = {}
        service.insert_job @project, link_table_config(table, urls, options)
      end

      def extract_table table, storage_files, options = {}
        service.insert_job @project, extract_table_config(table, storage_files, options)
      end

      def load_table table, storage_url, options = {}
        service.insert_job @project, load_table_config(table, storage_url,
                                         Array(storage_url).first, options)
      end

      def load_multipart table, file, options = {}
        mime_type = "application/octet-stream"
        service.insert_job @project,
                           load_table_config(table, nil, file, options),
                           upload_source: file,
                           content_type: mime_type # TODO verify this is correct
      end

      def load_resumable table, file, chunk_size = nil, options = {}
        # media = load_media file, chunk_size
        #
        # result = service.insert_job @project, job_object
        #   api_method: @bigquery.jobs.insert,
        #   media: media,
        #   parameters: { projectId: @project, uploadType: "resumable" },
        #   body_object: load_table_config(table, nil, file, options)
        # )
        # upload = result.resumable_upload
        # result = execute upload while upload.resumable?
        # result TODO: How to do this with gapi 0.9?
      end

      def default_access_rules
        [
          API::Access.new(role: "OWNER",  special_group: "projectOwners"),
          API::Access.new(role: "WRITER", special_group: "projectWriters"),
          API::Access.new(role: "READER", special_group: "projectReaders"),
          API::Access.new(role: "OWNER",  user_by_email: credentials.issuer)
        ]
      end

      ##
      # Extracts at least `tbl` group, and possibly `dts` and `prj` groups,
      # from strings in the formats: "my_table", "my_dataset.my_table", or
      # "my-project:my_dataset.my_table". Then merges project_id and
      # dataset_id from the default table if they are missing.
      def self.table_ref_from_s str, default_table_ref
        str = str.to_s
        m = /\A(((?<prj>\S*):)?(?<dts>\S*)\.)?(?<tbl>\S*)\z/.match str
        unless m
          fail ArgumentError, "unable to identify table from #{str.inspect}"
        end
        str_table_ref = API::TableReference.new(
          project_id: m["prj"],
          dataset_id: m["dts"],
          table_id: m["tbl"]
        )
        str_table_ref.project_id ||= default_table_ref.project_id
        str_table_ref.dataset_id ||= default_table_ref.dataset_id
        str_table_ref
      end

      def inspect
        "#{self.class}(#{@project})"
      end

      protected

      ##
      # Create the HTTP body for insert dataset
      def insert_dataset_request dataset_id, options = {}
        args = {
          kind: "bigquery#dataset",
          dataset_reference: API::DatasetReference.new(
            project_id: @project,
            dataset_id: dataset_id
          ),
          friendly_name: options[:name],
          description: options[:description],
          default_table_expiration_ms: options[:expiration],
          access: options[:access],
          location: options[:location]
        }.delete_if { |_, v| v.nil? }
        API::Dataset.new(args)
      end

      def patch_dataset_request options = {}
        API::Dataset.new(
          friendly_name: options[:name],
          description: options[:description],
          default_table_expiration_ms: options[:default_expiration],
          access: options[:access]
        )
      end

      ##
      # Create the HTTP body for insert table
      def insert_table_request dataset_id, table_id, options = {}
        args = {
          table_reference: API::TableReference.new(
            project_id: @project,
            dataset_id: dataset_id,
            table_id: table_id
          ),
          friendly_name: options[:name],
          description: options[:description],
          schema: options[:schema]
        }.delete_if { |_, v| v.nil? }
        args.view = { query: options[:query] } if options[:query]
        API::Table.new(args)
      end

      def patch_table_request options = {}
        body = API::Table.new(
          friendly_name: options[:name],
          description: options[:description],
          schema: options[:schema]
        )
        body.view = { query: options[:query] } if options[:query]
        body
      end

      def insert_tabledata_rows rows, options = {}
        API::InsertAllTableDataRequest.new(
          kind: "bigquery#tableDataInsertAllRequest",
          skip_invalid_rows: options[:skip_invalid],
          ignore_unknown_values: options[:ignore_unknown],
          rows: rows.map do |row|
            API::InsertAllTableDataRequest::Row.new(
              insert_id: Digest::MD5.base64digest(row.inspect),
              json: row
            )
          end
        )
      end

      # rubocop:disable all
      # Disabled rubocop because the API is verbose and so these methods
      # are going to be verbose.

      ##
      # Job description for query job
      def query_table_config query, options
        dest_table = nil
        if options[:table]
          dest_table = API::TableReference.new(
            project_id: options[:table].project_id,
            dataset_id: options[:table].dataset_id,
            table_id: options[:table].table_id
          )
        end
        default_dataset = nil
        if dataset = options[:dataset]
          if dataset.respond_to? :dataset_id
            default_dataset = API::DatasetReference.new(
              project_id: dataset.project_id,
              dataset_id: dataset.dataset_id
            )
          else
            default_dataset = API::DatasetReference.new dataset_id: dataset
          end
        end
        API::Job.new(
          configuration: API::JobConfiguration.new(
            query: API::JobConfigurationQuery.new(
              query: query,
              # tableDefinitions: { ... },
              priority: priority_value(options[:priority]),
              use_query_cache: options[:cache],
              destination_table: dest_table,
              create_disposition: create_disposition(options[:create]),
              write_disposition: write_disposition(options[:write]),
              allow_large_results: options[:large_results],
              flatten_results: options[:flatten],
              default_dataset: default_dataset
            )
          )
        )
      end

      def query_config query, options = {}
        dataset_config = nil
        dataset_config = API::DatasetReference.new(
          dataset_id: options[:dataset],
          project_id: options[:project] || @project
        ) if options[:dataset]

        API::QueryRequest.new(
          kind: "bigquery#queryRequest",
          query: query,
          max_results: options[:max],
          default_dataset: dataset_config,
          timeout_ms: options[:timeout],
          dry_run: options[:dryrun],
          use_query_cache: options[:cache]
        )
      end

      ##
      # Job description for copy job
      def copy_table_config source, target, options = {}
        API::Job.new(
          configuration: API::JobConfiguration.new(
            copy: API::JobConfigurationTableCopy.new(
              source_table: source,
              destination_table: target,
              create_disposition: create_disposition(options[:create]),
              write_disposition: write_disposition(options[:write])
            ),
            dry_run: options[:dryrun]
          )
        )
      end

      def link_table_config table, urls, options = {} # TODO: remove
        path = Array(urls).first
        API::Job.new(
          configuration: API::JobConfiguration.new(
            link: API::Dataset.new(
              source_uri: Array(urls),
              destination_table: table,
              create_disposition: create_disposition(options[:create]),
              write_disposition: write_disposition(options[:write]),
              source_format: source_format(path, options[:format])
            ),
            dry_run: options[:dryrun]
          )
        )
      end

      def extract_table_config table, storage_files, options = {}
        storage_urls = Array(storage_files).map do |url|
          url.respond_to?(:to_gs_url) ? url.to_gs_url : url
        end
        dest_format = source_format storage_urls.first, options[:format]
        API::Job.new(
          configuration: API::JobConfiguration.new(
            extract: API::JobConfigurationExtract.new(
              destination_uris: Array(storage_urls),
              source_table: table,
              destination_format: dest_format,
              compression: options[:compression],
              field_delimiter: options[:delimiter],
              print_header: options[:header]
            ),
            dry_run: options[:dryrun]
          )
        )
      end

      def load_table_config table, urls, file, options = {}
        path = Array(urls).first
        path = Pathname(file).to_path unless file.nil?
        API::Job.new(
          configuration: API::JobConfiguration.new(
            load: API::JobConfigurationLoad.new(
              source_uris: Array(urls),
              destination_table: table,
              create_disposition: create_disposition(options[:create]),
              write_disposition: write_disposition(options[:write]),
              source_format: source_format(path, options[:format]),
              projection_fields: projection_fields(options[:projection_fields]),
              allow_jagged_rows: options[:jagged_rows],
              allow_quoted_newlines: options[:quoted_newlines],
              encoding: options[:encoding],
              field_delimiter: options[:delimiter],
              ignore_unknown_values: options[:ignore_unknown],
              max_bad_records: options[:max_bad_records],
              quote: options[:quote],
              schema: options[:schema],
              skip_leading_rows: options[:skip_leading]
            ),
            dry_run: options[:dryrun]
          )
        )
      end

      def create_disposition str
        { "create_if_needed" => "CREATE_IF_NEEDED",
          "createifneeded" => "CREATE_IF_NEEDED",
          "if_needed" => "CREATE_IF_NEEDED",
          "needed" => "CREATE_IF_NEEDED",
          "create_never" => "CREATE_NEVER",
          "createnever" => "CREATE_NEVER",
          "never" => "CREATE_NEVER" }[str.to_s.downcase]
      end

      def write_disposition str
        { "write_truncate" => "WRITE_TRUNCATE",
          "writetruncate" => "WRITE_TRUNCATE",
          "truncate" => "WRITE_TRUNCATE",
          "write_append" => "WRITE_APPEND",
          "writeappend" => "WRITE_APPEND",
          "append" => "WRITE_APPEND",
          "write_empty" => "WRITE_EMPTY",
          "writeempty" => "WRITE_EMPTY",
          "empty" => "WRITE_EMPTY" }[str.to_s.downcase]
      end

      def priority_value str
        { "batch" => "BATCH",
          "interactive" => "INTERACTIVE" }[str.to_s.downcase]
      end

      def source_format path, format
        val = { "csv" => "CSV",
                "json" => "NEWLINE_DELIMITED_JSON",
                "newline_delimited_json" => "NEWLINE_DELIMITED_JSON",
                "avro" => "AVRO",
                "datastore" => "DATASTORE_BACKUP",
                "datastore_backup" => "DATASTORE_BACKUP"}[format.to_s.downcase]
        return val unless val.nil?
        return nil if path.nil?
        return "CSV" if path.end_with? ".csv"
        return "NEWLINE_DELIMITED_JSON" if path.end_with? ".json"
        return "AVRO" if path.end_with? ".avro"
        return "DATASTORE_BACKUP" if path.end_with? ".backup_info"
        nil
      end

      def projection_fields array_or_str
        Array(array_or_str) unless array_or_str.nil?
      end

      # rubocop:enable all
    end
  end
end
