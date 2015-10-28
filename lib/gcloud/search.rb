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

require "gcloud"

#--
# Google Cloud Search
module Gcloud
  ##
  # Creates a new +Project+ instance connected to the Search service.
  # Each call creates a new connection.
  #
  # === Parameters
  #
  # +project+::
  #   Identifier for a Search project. If not present, the default project for
  #   the credentials is used. (+String+)
  # +keyfile+::
  #   Keyfile downloaded from Google Cloud. If file path the file must be
  #   readable. (+String+ or +Hash+)
  # +options+::
  #   An optional Hash for controlling additional behavior. (+Hash+)
  # <code>options[:scope]</code>::
  #   The OAuth 2.0 scopes controlling the set of resources and operations that
  #   the connection can access. See {Using OAuth 2.0 to Access Google
  #   APIs}[https://developers.google.com/identity/protocols/OAuth2]. (+String+
  #   or +Array+)
  #
  #   The default scope is:
  #
  #   TODO insert scope string
  #
  # === Returns
  #
  # Gcloud::Search::Project
  #
  # === Example
  #
  #   require "gcloud"
  #
  #   search = Gcloud.search "my-search-project",
  #                    "/path/to/keyfile.json"
  #
  #   zone = search.zone "example-com"
  #
  def self.search project = nil, keyfile = nil, options = {}
    # project ||= Gcloud::Search::Project.default_project
    # if keyfile.nil?
    #   credentials = Gcloud::Search::Credentials.default options
    # else
    #   credentials = Gcloud::Search::Credentials.new keyfile, options
    # end
    # Gcloud::Search::Project.new project, credentials
  end

  ##
  # = Google Cloud Search
  #
  # Google Cloud Search allows an application to quickly perform full-text and
  # geo-spatial searches without having to spin up instances
  # and without the hassle of managing and maintaining a search service.
  #
  # Cloud Search provides a model for indexing documents containing structured data,
  # with documents and indexes saved to a separate persistent store optimized
  # for search operations.
  #
  # The API supports full text matching on string fields and allows indexing
  # any number of documents in any number of indexes.
  #
  # Gcloud's goal is to provide an API that is familiar and comfortable to
  # Rubyists. Authentication is handled by Gcloud#search. You can provide
  # the project and credential information to connect to the Cloud Search service,
  # or if you are running on Google Compute Engine this configuration is taken
  # care of for you. You can read more about the options for connecting in the
  # {Authentication Guide}[link:AUTHENTICATION.md].
  #
  # == Listing Indexes
  #
  # Indexes are searchable collections of documents.
  #
  # List all indexes in the project:
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   search = gcloud.search
  #
  #   indexes = search.indexes  # API call
  #   indexes.each do |index|
  #     puts index.name
  #     index.fields.each do |field|
  #       puts "- #{field.name}"
  #     end
  #   end
  #
  # Create a new index:
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   search = gcloud.search
  #
  #   new_index = search.index "products"
  #
  # Indexes cannot be created, updated, or deleted directly on the server:
  # they are derived from the documents which are created "within" them.
  #
  # == Documents
  #
  # Create a document instance, which is not yet added to its index on
  # the server. You can provide your own unique document id (as shown below),
  # which can be handy for updating a document (actually replacing it) without
  # having to retrieve it first through a query in order to obtain its id.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   search = gcloud.search
  #
  #   index = search.index "products"
  #   document = index.document "product-sku-000001"
  #   document.exists?  # API call
  #   #=> False
  #   document.rank
  #   #=> None
  #
  # Add one or more fields to the document. Since the document's id is not
  # a field and thus is not returned in query results, it is a good idea to also
  # set the value in a field when providing your own document id.
  #
  #   field = document.field "sku"
  #   field.add_value "product-sku-000001", type: :atom
  #
  # Save the document into the index:
  #
  #   document.create  # API call
  #   document.exists  # API call
  #   #=> True
  #   document.rank      # set by the server
  #   #=> 1443648166
  #
  # List all documents in an index:
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   search = gcloud.search
  #
  #   documents = index.documents  # API call
  #   documents.map &:id #=> ["product-sku-000001"]
  #
  # Delete a document from its index:
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   search = gcloud.search
  #
  #   document = index.document "product-sku-000001"
  #   document.exists  # API call
  #   #=> True
  #   document.delete  # API call
  #   document.exists  # API call
  #   #=> False
  #
  # To update a document in place after manipulating its fields or rank, just
  # recreate it:  E.g.:
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   search = gcloud.search
  #
  #   document = index.document "product-sku-000001"
  #   document.exists  # API call
  #   #=> True
  #   document.rank = 12345
  #   field = document.field "price"
  #   field.add_value 24.95
  #   document.create  # API call
  #
  # == Fields
  #
  # Fields belong to documents and are the data that actually gets searched.
  #
  # Each field can have multiple values, which can be of the following types:
  #
  # - String
  # - Number
  # - Time
  # - Geovalue
  #
  # String values can be tokenized using one of three different types of
  # tokenization, which can be passed when the value is added:
  #
  # - :atom means "don't tokenize this string", treat it as one
  #   thing to compare against.
  #
  # - :text means "treat this string as normal text" and split words
  #   apart to be compared against.
  #
  # - :html means "treat this string as HTML", understanding the
  #   tags, and treating the rest of the content like Text.
  #
  # More than one value can be added to a field.
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   search = gcloud.search
  #
  #   index = search.index "products"
  #   document = index.document "product-sku-000001"
  #   field = document.field "description"
  #   field.add_value "The best T-shirt ever.", type: :text, lang: "en"
  #   field.add_value "<p>The best T-shirt ever.</p>", type: :html, lang: "en"
  #
  # == Searching
  #
  # After populating an index with documents, search through them by
  # issuing a search query:
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   search = gcloud.search
  #
  #   index = search.index "products"
  #   query = search.query "t-shirt"
  #   documents = index.search query  # API call
  #   documents.map &:id #=> ["product-sku-000001"]
  #
  # By default, all queries are sorted by the rank value set when the
  # document was created. For more information see the {REST API
  # documentation for Document.rank}[https://cloud.google.com/search/reference/rest/v1/projects/indexes/documents#resource_representation.google.cloudsearch.v1.Document.rank].
  #
  # To sort differently, use the :order_by option:
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   search = gcloud.search
  #
  #   query = search.query "t-shirt", order_by: ["price", "-avg_review"]
  #   documents = index.search query  # API call
  #
  # Note that the - character before avg_review means that this query will
  # be sorted ascending by price and then descending by avg_review.
  #
  # To limit the fields to be returned in the match, use the :fields option:
  #
  #   require "gcloud"
  #
  #   gcloud = Gcloud.new
  #   search = gcloud.search
  #
  #   query = search.query "t-shirt", fields: ["sku", "description"]
  #   documents = index.search query  # API call
  #
  # == Fields (discussion)
  #
  # The current Search JSON API is fairly simple; Document fields are probably
  # the hardest part of it to understand. We need to decide the best way
  # for our own API to manage fields.
  #
  # == Setting fields
  #
  # ==== Option 1: Grouped by name
  #
  # Multiple field values are set on a Field object created by name. This is the
  # approach taken by the REST API as well as gcloud-python. (What should happen if a
  # Field with the same name already exists? The gcloud-python impl appears to
  # replace it with a new one.)
  #
  #   document = index.document "product-sku-000001"
  #
  #   field = document.field "description"
  #   field.add_value "100% organic cotton ruby gem T-shirt",
  #                   type: :text,
  #                   lang: "en"
  #   field.add_value "<p>100% organic cotton ruby gem T-shirt</p>",
  #                   type: :html,
  #                   lang: "en"
  #   field.values.count #=> 2
  #
  # ==== Option 2: Flat
  #
  # Fields are added to a single collection. Field name is not unique.
  #
  #   document = index.document "product-sku-000001"
  #
  #   document.add_field "description",
  #                      "100% organic cotton ruby gem T-shirt",
  #                      type: :text,
  #                      lang: "en"
  #
  #   document.add_field "description",
  #                      "<p>100% organic cotton ruby gem T-shirt</p>",
  #                      type: :html,
  #                      lang: "en"
  #   document.fields_by(name: "description").count #=> 2
  #
  # An advantage of the flat structure is that you don't have to go through the
  # extra step of creating/retrieving a collecting Field object in order to add
  # a field value. A disadvantage is that it is a little harder to inspect the
  # values you have already added.
  #
  # == Getting fields
  #
  # ==== Option 1: Grouped by name
  #
  # Fields are returned grouped by name, as a hash of objects. This is
  # the approach taken by the REST API as well as gcloud-python.
  #
  #   document = index.document "product-sku-000001"
  #
  #   field = document.fields["description"]
  #
  #   field.values[0].field.name #=> "description"
  #   field.values[0].value #=> "100% organic cotton ruby gem T-shirt"
  #   field.values[0].type #=> :text
  #   field.values[0].lang #=> "en"
  #   field.values[1].field.name #=> "description"
  #   field.values[1].value #=> "<p>100% organic cotton ruby gem T-shirt</p>"
  #   field.values[1].type #=> :html
  #   field.values[1].lang #=> "en"
  #
  # Each value contains a reference back to its field. (Without it, building an array of
  # values collected from multiple fields is problematic, since the names are lost.)
  #
  # ==== Option 2: Flat
  #
  # Fields are returned flat, in a single array, with non-unique name. They
  # can be filtered (grouped) in Ruby using Document#fields_by or Array#select.
  #
  #   index = search.index "products"
  #   query = search.query "t-shirt"
  #   document = index.document "product-sku-000001"
  #
  #   fields = document.fields_by(name: "description")
  #   # Same as
  #   fields = document.fields.select {|f| f.name == "description"}
  #
  #   fields[0].name #=> "description"
  #   fields[0].value #=> "100% organic cotton ruby gem T-shirt"
  #   fields[0].type #=> :text
  #   fields[0].lang #=> "en"
  #   fields[1].name #=> "description"
  #   fields[1].value #=> "<p>100% organic cotton ruby gem T-shirt</p>"
  #   fields[1].type #=> :html
  #   fields[1].lang #=> "en"
  #
  # An advantage of the flat structure is that the fields can just as easily
  # be filtered by a different attribute. In practice, I have found that pre-grouped
  # data structures often do more harm than good. An example is the
  # [Zonefile](https://github.com/boesemar/zonefile) library, which returns RRs
  # in a hash grouped by type. The values do not contain the type, so converting
  # to a flat structure that included type and the other attributes in each
  # element is a chore.
  #
  # You can just as easily filter the fields by attributes other than name.
  #
  #   index = search.index "products"
  #   query = search.query "t-shirt"
  #   document = index.document "product-sku-000001"
  #
  #   fields = document.fields_by(type: :html, lang: "en")
  #   # Same as
  #   fields = document.fields.select {|f| f.type == :html && f.lang == "en"}
  #
  #   fields[0].name #=> "description"
  #   fields[0].value #=> "<p>100% organic cotton ruby gem T-shirt</p>"
  #   fields[0].type #=> :html
  #   fields[0].lang #=> "en"
  #
  module Search
  end
end
