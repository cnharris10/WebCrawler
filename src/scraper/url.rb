require_relative "./config"
require_relative "./logger"
require_relative "./redis"

module Scraper
  class Url

    attr_accessor :raw_url, :url

    def initialize(url = nil)
      return nil if url.nil?
      @raw_url = url.downcase.strip
      return nil unless validate
    end

    def https?
      return false if @url.nil?
      !Socket.getaddrinfo(@url.host, "https").nil?
    end

    def http?
      return false if @url.nil?
      !Socket.getaddrinfo(@url.host, "http").nil?
    end

    def to_s
      @url.to_s
    end

    def self.sanitize_url(page, href)
      return if page.nil? || href.nil?
      return if href.start_with?("javascript") 
      page_uri = URI.parse(page.url.to_s)
      sanitized_href = if href[0,2] == "//"
                         "#{page_uri.scheme}:#{href}"
                       elsif href[0,1] == "/"
                         "#{page_uri.scheme}://#{page_uri.host}#{href}"
                       elsif href[0,1] == "#"
                         "#{page_uri.scheme}://#{page_uri.host}#{page_uri.path}#{href}"
                       else
                         href
                       end
      ::ScraperLogger.debug "Sanitized href: #{sanitized_href} from #{href}"
      sanitized_href
    end

    private

      def validate
        raise if @raw_url.nil?
        split_and_construct_url
        raise if @url.nil?
        raise unless http? || https?
        true
        rescue SocketError
          ::ScraperLogger.debug "Invalid Url: #{url} - Method: validate"
          return false
      end

      def split_and_construct_url
        split_url = URI.split(@raw_url)
        zipped_args = Hash[Scraper::URL_PARTS.zip(split_url)]
        @url = URI::HTTP.build(zipped_args)
      end

  end
end