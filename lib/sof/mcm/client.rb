# frozen_string_literal: true

require "base64"
require "uri"
require "json"
require "net_http_timeout_errors"
require_relative "request"

module SOF
  module MCM
    class Client
      # Standard HTTP GET and PUT methods
      @http_getter = Get.with_verify(true)
      @http_putter = Put.with_verify(true)

      class << self
        # Allow the http_getter and http_putter to be overridden
        # The getter will receive a URI object
        # The putter will receive a URL string, a body string, and a headers hash
        attr_accessor :http_getter, :http_putter
      end

      def initialize(
        env = ENV,
        http_getter: self.class.http_getter,
        http_putter: self.class.http_putter
      )
        @env = env
        @http_getter = http_getter
        @http_putter = http_putter
      end
      attr_reader :env, :http_getter, :http_putter

      # List all applications in the MCM
      def applications(headers: {})
        http_getter.call(
          URI(url_for_action(:list_applications)),
          nil,
          default_headers.merge(headers)
        )
      end

      #  Assign User to Application in a Site:
      # - Responses:
      # - 200: {'status':'success'}
      # - 401: {'status':'failure', 'reason': 'reason added'} # if credentials are bad
      # - 403: {'status':'failure', 'reason': 'reason added'} # if validation fails
      # - 500: HTML if something catastrophic happens
      def assign(edipi, application_uid:, comment: "Assigning user")
        update_user(edipi, :assign_user_to_application, application_uid:, comment:)
      end

      # Unassign User from Application in a Site
      def unassign(edipi, application_uid:, comment: "Unassigning user")
        update_user(edipi, :unassign_user_from_application, application_uid:, comment:)
      end

      def url_for_action(action)
        "#{env.fetch("MCM_URL")}/@#{action}"
      end

      def update_user(edipi, action, application_uid:, comment: nil)
        response = http_putter.call(
          url_for_action(action),
          {
            user_id: edipi,
            application_uid:,
            comment:,
            role: "Pub Member"
          }.to_json,
          default_headers
        )

        body = JSON.parse(response.body)
        if body["status"] == "failure"
          raise MCM::Error, %(MCM returned status #{response.code}: #{body["reason"]})
        else
          response
        end
      rescue *NetHttpTimeoutErrors.all => e
        raise MCM::Error, %(MCM request failed with a timeout: #{e.message})
      end

      def default_headers
        {
          "Accept" => "application/json",
          "Content-Type" => "application/json",
          "Authorization" => "Basic #{Base64.strict_encode64("#{env.fetch("MCM_USERNAME")}:#{env.fetch("MCM_PASSWORD")}")}"
        }
      end
    end
  end
end
