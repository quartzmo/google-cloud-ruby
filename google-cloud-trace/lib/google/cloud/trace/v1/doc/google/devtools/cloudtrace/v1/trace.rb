# Copyright 2019 Google LLC
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


module Google
  module Devtools
    module Cloudtrace
      module V1
        # A trace describes how long it takes for an application to perform an
        # operation. It consists of a set of spans, each of which represent a single
        # timed event within the operation.
        # @!attribute [rw] project_id
        #   @return [String]
        #     Project ID of the Cloud project where the trace data is stored.
        # @!attribute [rw] trace_id
        #   @return [String]
        #     Globally unique identifier for the trace. This identifier is a 128-bit
        #     numeric value formatted as a 32-byte hex string.
        # @!attribute [rw] spans
        #   @return [Array<Google::Devtools::Cloudtrace::V1::TraceSpan>]
        #     Collection of spans in the trace.
        class Trace; end

        # List of new or updated traces.
        # @!attribute [rw] traces
        #   @return [Array<Google::Devtools::Cloudtrace::V1::Trace>]
        #     List of traces.
        class Traces; end

        # A span represents a single timed event within a trace. Spans can be nested
        # and form a trace tree. Often, a trace contains a root span that describes the
        # end-to-end latency of an operation and, optionally, one or more subspans for
        # its suboperations. Spans do not need to be contiguous. There may be gaps
        # between spans in a trace.
        # @!attribute [rw] span_id
        #   @return [Integer]
        #     Identifier for the span. Must be a 64-bit integer other than 0 and
        #     unique within a trace.
        # @!attribute [rw] kind
        #   @return [Google::Devtools::Cloudtrace::V1::TraceSpan::SpanKind]
        #     Distinguishes between spans generated in a particular context. For example,
        #     two spans with the same name may be distinguished using `RPC_CLIENT`
        #     and `RPC_SERVER` to identify queueing latency associated with the span.
        # @!attribute [rw] name
        #   @return [String]
        #     Name of the span. Must be less than 128 bytes. The span name is sanitized
        #     and displayed in the Stackdriver Trace tool in the
        #     Google Cloud Platform Console.
        #     The name may be a method name or some other per-call site name.
        #     For the same executable and the same call point, a best practice is
        #     to use a consistent name, which makes it easier to correlate
        #     cross-trace spans.
        # @!attribute [rw] start_time
        #   @return [Google::Protobuf::Timestamp]
        #     Start time of the span in nanoseconds from the UNIX epoch.
        # @!attribute [rw] end_time
        #   @return [Google::Protobuf::Timestamp]
        #     End time of the span in nanoseconds from the UNIX epoch.
        # @!attribute [rw] parent_span_id
        #   @return [Integer]
        #     ID of the parent span, if any. Optional.
        # @!attribute [rw] labels
        #   @return [Hash{String => String}]
        #     Collection of labels associated with the span. Label keys must be less than
        #     128 bytes. Label values must be less than 16 kilobytes (10MB for
        #     `/stacktrace` values).
        #
        #     Some predefined label keys exist, or you may create your own. When creating
        #     your own, we recommend the following formats:
        #
        #     * `/category/product/key` for agents of well-known products (e.g.
        #       `/db/mongodb/read_size`).
        #     * `short_host/path/key` for domain-specific keys (e.g.
        #       `foo.com/myproduct/bar`)
        #
        #     Predefined labels include:
        #
        #     * `/agent`
        #     * `/component`
        #     * `/error/message`
        #     * `/error/name`
        #     * `/http/client_city`
        #     * `/http/client_country`
        #     * `/http/client_protocol`
        #     * `/http/client_region`
        #     * `/http/host`
        #     * `/http/method`
        #     * `/http/path`
        #     * `/http/redirected_url`
        #     * `/http/request/size`
        #     * `/http/response/size`
        #     * `/http/route`
        #     * `/http/status_code`
        #     * `/http/url`
        #     * `/http/user_agent`
        #     * `/pid`
        #     * `/stacktrace`
        #     * `/tid`
        class TraceSpan
          # Type of span. Can be used to specify additional relationships between spans
          # in addition to a parent/child relationship.
          module SpanKind
            # Unspecified.
            SPAN_KIND_UNSPECIFIED = 0

            # Indicates that the span covers server-side handling of an RPC or other
            # remote network request.
            RPC_SERVER = 1

            # Indicates that the span covers the client-side wrapper around an RPC or
            # other remote request.
            RPC_CLIENT = 2
          end
        end

        # The request message for the `ListTraces` method. All fields are required
        # unless specified.
        # @!attribute [rw] project_id
        #   @return [String]
        #     ID of the Cloud project where the trace data is stored.
        # @!attribute [rw] view
        #   @return [Google::Devtools::Cloudtrace::V1::ListTracesRequest::ViewType]
        #     Type of data returned for traces in the list. Optional. Default is
        #     `MINIMAL`.
        # @!attribute [rw] page_size
        #   @return [Integer]
        #     Maximum number of traces to return. If not specified or <= 0, the
        #     implementation selects a reasonable value.  The implementation may
        #     return fewer traces than the requested page size. Optional.
        # @!attribute [rw] page_token
        #   @return [String]
        #     Token identifying the page of results to return. If provided, use the
        #     value of the `next_page_token` field from a previous request. Optional.
        # @!attribute [rw] start_time
        #   @return [Google::Protobuf::Timestamp]
        #     Start of the time interval (inclusive) during which the trace data was
        #     collected from the application.
        # @!attribute [rw] end_time
        #   @return [Google::Protobuf::Timestamp]
        #     End of the time interval (inclusive) during which the trace data was
        #     collected from the application.
        # @!attribute [rw] filter
        #   @return [String]
        #     An optional filter against labels for the request.
        #
        #     By default, searches use prefix matching. To specify exact match, prepend
        #     a plus symbol (`+`) to the search term.
        #     Multiple terms are ANDed. Syntax:
        #
        #     * `root:NAME_PREFIX` or `NAME_PREFIX`: Return traces where any root
        #       span starts with `NAME_PREFIX`.
        #     * `+root:NAME` or `+NAME`: Return traces where any root span's name is
        #       exactly `NAME`.
        #     * `span:NAME_PREFIX`: Return traces where any span starts with
        #       `NAME_PREFIX`.
        #     * `+span:NAME`: Return traces where any span's name is exactly
        #       `NAME`.
        #     * `latency:DURATION`: Return traces whose overall latency is
        #       greater or equal to than `DURATION`. Accepted units are nanoseconds
        #       (`ns`), milliseconds (`ms`), and seconds (`s`). Default is `ms`. For
        #       example, `latency:24ms` returns traces whose overall latency
        #       is greater than or equal to 24 milliseconds.
        #     * `label:LABEL_KEY`: Return all traces containing the specified
        #       label key (exact match, case-sensitive) regardless of the key:value
        #       pair's value (including empty values).
        #     * `LABEL_KEY:VALUE_PREFIX`: Return all traces containing the specified
        #       label key (exact match, case-sensitive) whose value starts with
        #       `VALUE_PREFIX`. Both a key and a value must be specified.
        #     * `+LABEL_KEY:VALUE`: Return all traces containing a key:value pair
        #       exactly matching the specified text. Both a key and a value must be
        #       specified.
        #     * `method:VALUE`: Equivalent to `/http/method:VALUE`.
        #     * `url:VALUE`: Equivalent to `/http/url:VALUE`.
        # @!attribute [rw] order_by
        #   @return [String]
        #     Field used to sort the returned traces. Optional.
        #     Can be one of the following:
        #
        #     * `trace_id`
        #     * `name` (`name` field of root span in the trace)
        #     * `duration` (difference between `end_time` and `start_time` fields of
        #       the root span)
        #     * `start` (`start_time` field of the root span)
        #
        #     Descending order can be specified by appending `desc` to the sort field
        #     (for example, `name desc`).
        #
        #     Only one sort field is permitted.
        class ListTracesRequest
          # Type of data returned for traces in the list.
          module ViewType
            # Default is `MINIMAL` if unspecified.
            VIEW_TYPE_UNSPECIFIED = 0

            # Minimal view of the trace record that contains only the project
            # and trace IDs.
            MINIMAL = 1

            # Root span view of the trace record that returns the root spans along
            # with the minimal trace data.
            ROOTSPAN = 2

            # Complete view of the trace record that contains the actual trace data.
            # This is equivalent to calling the REST `get` or RPC `GetTrace` method
            # using the ID of each listed trace.
            COMPLETE = 3
          end
        end

        # The response message for the `ListTraces` method.
        # @!attribute [rw] traces
        #   @return [Array<Google::Devtools::Cloudtrace::V1::Trace>]
        #     List of trace records returned.
        # @!attribute [rw] next_page_token
        #   @return [String]
        #     If defined, indicates that there are more traces that match the request
        #     and that this value should be passed to the next request to continue
        #     retrieving additional traces.
        class ListTracesResponse; end

        # The request message for the `GetTrace` method.
        # @!attribute [rw] project_id
        #   @return [String]
        #     ID of the Cloud project where the trace data is stored.
        # @!attribute [rw] trace_id
        #   @return [String]
        #     ID of the trace to return.
        class GetTraceRequest; end

        # The request message for the `PatchTraces` method.
        # @!attribute [rw] project_id
        #   @return [String]
        #     ID of the Cloud project where the trace data is stored.
        # @!attribute [rw] traces
        #   @return [Google::Devtools::Cloudtrace::V1::Traces]
        #     The body of the message.
        class PatchTracesRequest; end
      end
    end
  end
end