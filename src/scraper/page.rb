require "nokogiri"
require "uri"
require "open_uri_redirections"

require_relative "./url"

module Scraper
	class Page

		attr_accessor :url, :html, :structured_html

		def initialize(url)
			@url = Scraper::Url.new(url)
			return nil if @url.nil?
		end

		# Fetch raw html for url
		def html
			return @html unless @html.nil?
			escaped_url = URI.escape(@url.to_s)
			::ScraperLogger.debug "Escaped Url: #{escaped_url}"
			@html = open(escaped_url, allow_redirections: :all).read
		end

		# Convert raw html into structured data
		def structured_html
			@structured_html ||= ::Nokogiri::HTML(html)
		end

		# Determine if page is child of other url
		def is_child_of?(parent)
			parent_url_string = parent.url.to_s
			secondary_uri = URI.parse(parent_url_string)
			parent_url_host = @url.url.host
			child_url_host = secondary_uri.host
			return false if child_url_host.nil? || parent_url_host.nil?
			parent_url_host.include?(child_url_host) || child_url_host.include?(parent_url_host)
		end

	end
end