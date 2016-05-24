require_relative "./config"
require_relative "./logger"
require_relative "./redis"

require "byebug"

module Crawler
  class Url

    attr_accessor :raw_url, :url

    def initialize(url = nil)
      return nil if url.nil?
      @raw_url = URI.unescape(url.downcase.strip)
      validate
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
      ::CrawlerLogger.debug "Sanitized href: #{sanitized_href} from #{href}"
      sanitized_href
    end

    def self.unescape(url)
      return nil if url.nil?
      URI.unescape(url)
    end

    private

      def validate
        raise if @raw_url.nil?
        split_and_construct_url
        return true if http? || https?
        @url = nil
        return false
      end

      def split_and_construct_url
        split_url = URI.split(@raw_url)
        zipped_args = Hash[Crawler::URL_PARTS.zip(split_url)]
        @url = URI::HTTP.build(zipped_args) rescue nil
      end

  end
end