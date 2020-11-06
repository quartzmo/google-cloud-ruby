# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: google/cloud/websecurityscanner/v1beta/scan_run_error_trace.proto

require 'google/protobuf'

require 'google/cloud/websecurityscanner/v1beta/scan_config_error_pb'
Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("google/cloud/websecurityscanner/v1beta/scan_run_error_trace.proto", :syntax => :proto3) do
    add_message "google.cloud.websecurityscanner.v1beta.ScanRunErrorTrace" do
      optional :code, :enum, 1, "google.cloud.websecurityscanner.v1beta.ScanRunErrorTrace.Code"
      optional :scan_config_error, :message, 2, "google.cloud.websecurityscanner.v1beta.ScanConfigError"
      optional :most_common_http_error_code, :int32, 3
    end
    add_enum "google.cloud.websecurityscanner.v1beta.ScanRunErrorTrace.Code" do
      value :CODE_UNSPECIFIED, 0
      value :INTERNAL_ERROR, 1
      value :SCAN_CONFIG_ISSUE, 2
      value :AUTHENTICATION_CONFIG_ISSUE, 3
      value :TIMED_OUT_WHILE_SCANNING, 4
      value :TOO_MANY_REDIRECTS, 5
      value :TOO_MANY_HTTP_ERRORS, 6
    end
  end
end

module Google
  module Cloud
    module WebSecurityScanner
      module V1beta
        ScanRunErrorTrace = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.websecurityscanner.v1beta.ScanRunErrorTrace").msgclass
        ScanRunErrorTrace::Code = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("google.cloud.websecurityscanner.v1beta.ScanRunErrorTrace.Code").enummodule
      end
    end
  end
end