# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: google/cloud/billing/v1/cloud_catalog.proto for package 'google.cloud.billing.v1'
# Original file comments:
# Copyright 2019 Google LLC.
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
#
#

require 'grpc'
require 'google/cloud/billing/v1/cloud_catalog_pb'

module Google
  module Cloud
    module Billing
      module V1
        module CloudCatalog
          # A catalog of Google Cloud Platform services and SKUs.
          # Provides pricing information and metadata on Google Cloud Platform services
          # and SKUs.
          class Service

            include GRPC::GenericService

            self.marshal_class_method = :encode
            self.unmarshal_class_method = :decode
            self.service_name = 'google.cloud.billing.v1.CloudCatalog'

            # Lists all public cloud services.
            rpc :ListServices, ListServicesRequest, ListServicesResponse
            # Lists all publicly available SKUs for a given cloud service.
            rpc :ListSkus, ListSkusRequest, ListSkusResponse
          end

          Stub = Service.rpc_stub_class
        end
      end
    end
  end
end
