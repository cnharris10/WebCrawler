require "nokogiri"
require "open_uri_redirections"

require_relative "../crawler/config"
require_relative "../crawler/logger"
require_relative "../crawler/page"
require_relative "./email"

module Crawler
	class Crawl
	  @queue = :crawl

	  def self.perform(page_url)
	  	self.fetch_html(page_url)
	  end

	  def self.fetch_html(page_url)
	  	page = Crawler::Page.new(page_url)
	  	return nil if page.url.nil?

	  	# Enqueue Email scan
	  	::CrawlerLogger.info("Searching for emails in #{page_url}")
	  	Resque.enqueue(Crawler::Email, page.html)

	  	# Set page as crawled to bypass duplication
	  	REDIS_CLIENT.hset(Crawler::Queues::URLS, page.url.to_s, 1)

	    # Iterate through each anchor tag and validate 
	    page.anchors.each do |link|
	    	href = link.attr("href")
	    	parsed_href = Crawler::Url.sanitize_url(page, href)
	    	unless parsed_href.nil?
	    		subpage = Crawler::Page.new(parsed_href)
	    		self.enqueue_subpage(subpage) if subpage.is_related_to?(page)
	    	end
		  end
	  end

	  # To crawl or not to crawl
	  def self.enqueue_subpage(subpage)
	  	subpage_url_string = subpage.url.to_s

	  	# Return if url was already crawled
	  	return if REDIS_CLIENT.hget(Crawler::Queues::URLS, subpage_url_string)

	  	# Enqueue url to be crawled
    	Resque.enqueue(Crawler::Crawl, subpage.url.to_s)
	  end 

	end
end