require "nokogiri"
require "uri"
require 'watir-webdriver'

require_relative "./url"

module Crawler
	class Page

		attr_accessor :url, :html, :structured_html

		def initialize(url)
			@url = Crawler::Url.new(url)
		end

		# Fetch raw html for url
		def html
			return @html unless @html.nil?
			escaped_url = URI.escape(@url.to_s)
			::CrawlerLogger.debug "Fetching HTML for url: #{escaped_url}"
			browser = Watir::Browser.new(:phantomjs)
			browser.goto(escaped_url)
			@html = browser.html
			browser.close
			@html
		end

		# Convert raw html into structured data
		def structured_html
			@structured_html ||= ::Nokogiri::HTML(html)
		end

		def anchors
			structured_html.css("a")
		end

		# Determine if page is child of other url
		def is_related_to?(parent)
			parent_url_string = parent.url.to_s
			secondary_uri = URI.parse(parent_url_string)
			parent_url_host = @url.url.host
			child_url_host = secondary_uri.host
			return false if child_url_host.nil? || parent_url_host.nil?
			parent_url_host.include?(child_url_host) || child_url_host.include?(parent_url_host)
		end

	end
end