# frozen_string_literal: true

require "uri"
require "net/http"

module TTY
  module File
    DownloadError = Class.new(StandardError)

    class DownloadFile
      attr_reader :uri, :dest_path, :limit

      DEFAULT_REDIRECTS = 3

      # @options
      #
      def initialize(url, dest_path, limit: nil)
        @uri       = URI.parse(url)
        @dest_path = dest_path
        @limit     = limit || DEFAULT_REDIRECTS
      end

      # Download a file
      #
      # @api public
      def call
        download(uri, dest_path, limit)
      end

      private

      # @api private
      def download(uri, path, limit)
        raise DownloadError, "Redirect limit reached!" if limit.zero?
        content = []

        Net::HTTP.start(uri.host, uri.port,
                        use_ssl: uri.scheme == "https") do |http|
          http.request_get(uri.request_uri) do |response|
            case response
            when Net::HTTPSuccess
              response.read_body do |seg|
                content << seg
              end
            when Net::HTTPRedirection
              download(URI.parse(response["location"]), path, limit - 1)
            else
              response.error!
            end
          end
        end
        content.join
      end
    end # DownloadFile
  end # File
end # TTY
