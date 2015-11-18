#--
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

module Gcloud
  module Search
    # Disabled because there are links in the docs that are long, and a long
    # if/else chain.

    ##
    # = FieldValue
    #
    # A field can have multiple values with same or different types; however, it
    # cannot have multiple Timestamp or number values.
    #
    # For more information see {Documents and
    # fields}[https://cloud.google.com/search/documents_indexes].
    #
    class FieldValue
      attr_reader :name, :value, :type, :lang

      def initialize name, value, options = {}
        @name = name
        @value = value
        @type = options[:type].to_sym if options[:type]
        @type = infer_type if @type.nil?
        @lang = options[:lang] if string_type?
      end

      def string_type?
        [:atom, :default, :html, :text].include? type
      end

      protected

      def infer_type
        if value.respond_to?(:rfc3339)
          :timestamp
        elsif value.is_a? Numeric
          :number
        else
          :default
        end
      end
    end
  end
end
