require "nokogiri"
require "open_uri_redirections"

require_relative "../scraper/config"
require_relative "../scraper/logger"
require_relative "../scraper/page"
require_relative "./email"

module Scraper
	class Scrape
	  @queue = :scrape

	  def self.perform(page_url)
	  	self.fetch_html(page_url)
	  end

	  def self.fetch_html(page_url)
	  	page = Scraper::Page.new(page_url)
	  	return nil if page.nil?

	  	# Enqueue Email scan
	  	Resque.enqueue(Scraper::Email, page.html)

	  	# Parse HTML response via Nokogiri and find all anchor tags
	    structured_html = page.structured_html
	    anchors = structured_html.css("a")

	    # Iterate through each anchor tag and validate 
	    anchors.each do |link|
	    	href = link.attr("href")
	    	parsed_href = Scraper::Url.sanitize_url(page, href)
	    	parse_anchor_tag(page, parsed_href) unless parsed_href.nil?
		  end
	  end

	  # Determine if anchor tag belongs to parent domain
	  # and continue if so
	  def self.parse_anchor_tag(page, href)
			return if page.nil? || href.nil?
	  	unescaped_href = URI.unescape(href)
	  	subpage = Scraper::Page.new(unescaped_href)
	    self.track_and_fetch(subpage) if subpage.is_child_of?(page)
	  end

	  # If url has NOT been crawled, crawl it and set as crawled
	  def self.track_and_fetch(subpage)
	  	subpage_url_string = subpage.url.to_s
	  	return if REDIS_CLIENT.hget(Scraper::Queues::URLS, subpage_url_string)
    	REDIS_CLIENT.hset(Scraper::Queues::URLS, subpage_url_string, 1)
    	Resque.enqueue(Scraper::Scrape, subpage.url.to_s)
	  end 

	end
end