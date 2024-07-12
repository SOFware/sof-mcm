# frozen_string_literal: true

require_relative "mcm/version"
require_relative "mcm/client"

module SOF
  module MCM
    class Error < StandardError; end

    module_function

    # Returns a MCM::Client instance
    #
    # @param env [Hash] the environment to use for configuration
    #
    # @return [MCM::Client] the client
    def client(env = ENV, **)
      Client.new(env, **)
    end

    # Assigns a user to an application
    #
    # @param edipi [String] the user's EDIPI
    # @param application [String] the application to assign the user to
    # @param env [Hash] the environment to use for configuration
    def assign(edipi, application:, env: ENV, **kwargs)
      comment = kwargs.fetch(:comment, "Assigning user")
      config = kwargs.except(:comment)

      client = client(env, **config)
      body = client.applications.body

      parsed_body = JSON.parse(body)
      results = parsed_body.fetch("results")

      application_data = results.find { |app| app["id"] == application } || {}
      application_uid = application_data["uid"]
      if application_uid
        client.assign(edipi, application_uid:, comment:)
      else
        raise Error, "Unable to find application UID for #{application}"
      end
    rescue JSON::ParserError
      raise Error, "Unable to parse JSON response from MCM:\n#{body}"
    rescue KeyError
      raise Error, "Missing 'results' key in response from MCM:\n#{body}"
    end
  end
end
