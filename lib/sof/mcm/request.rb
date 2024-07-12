require "net/http"

module SOF
  module MCM
    class Request
      def self.with_verify(verify)
        veification = if verify
          OpenSSL::SSL::VERIFY_PEER
        else
          OpenSSL::SSL::VERIFY_NONE
        end
        proc do |url, body = nil, headers = nil|
          new(url, body, headers).tap do |instance|
            instance.verify_mode = veification
          end.call
        end
      end

      def self.call(url, body = nil, headers = nil)
        new(url, body, headers).call
      end

      def initialize(url, body, headers)
        @uri = URI(url)
        @body = body
        @headers = headers
        @http = Net::HTTP.new(uri.host, uri.port)
        @http.use_ssl = uri.scheme == "https"
      end
      attr_reader :http, :uri, :headers, :body

      class NotImplementedError < StandardError; end

      def verify_mode=(mode)
        http.verify_mode = mode
      end

      def request
        type.new(uri, headers).tap do |req|
          req.body = body if body
        end
      end

      def call
        http.request(request)
      end
    end

    class Get < Request
      def type = Net::HTTP::Get
    end

    class Put < Request
      def type = Net::HTTP::Put
    end
  end
end
