# frozen_string_literal: true

require "uri"
require "base64"
require "webmock/rspec"

module SOF
  module MCM
    module TestHelper
      def stub_mcm_headers(
        uri:, auth: "Basic #{Base64.strict_encode64("mcmapp:mcmapp")}",
        headers: {}
      )
        {
          "Accept" => "application/json",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => auth,
          "Content-Type" => "application/json",
          "Host" => URI(uri).host,
          "User-Agent" => "Ruby"
        }.merge(headers)
      end

      def stub_mcm_list_applications(
        uri:,
        results: [],
        auth: "Basic #{Base64.strict_encode64("mcmapp:mcmapp")}"
      )
        stub_request(:get, "#{uri}/@list_applications")
          .with(
            headers: stub_mcm_headers(uri:, auth:)
          )
          .to_return(
            status: 200,
            body: {
              "results" => results
            }.to_json,
            headers: {}
          )
      end

      def stub_mcm_put(
        edipi,
        uri:, status: 200,
        action: "assign_user_to_application",
        comment: "Assigning user",
        authorization: "Basic #{Base64.strict_encode64("mcmapp:mcmapp")}",
        application_uid: "mcmapp",
        request_body: {},
        request_headers: {},
        response_body: {},
        response_headers: {}
      )
        headers = stub_mcm_headers(
          auth: authorization,
          uri:,
          headers: request_headers
        )

        body = {
          user_id: edipi,
          application_uid:,
          comment:,
          role: "Pub Member"
        }.merge(request_body).to_json

        stub_request(:put, "#{uri}/@#{action}")
          .with(
            body:,
            headers:
          )
          .to_return(status:, body: response_body.to_json, headers: response_headers)
      end
    end
  end
end
