# Crawler

## Introduction

This is a BFS headless crawler that utilizes Redis/Resque to queue 2 types of operations:

**crawl.rb**<br/>
Fetches a given url's html contents and queues all discovered anchor tag href links.

**email.rb**<br/>
Scan for all emails (via regex) within a document and store each in a Redis Set.

As Resque jobs are running, Redis is being polled for updates to the email set.

## Demo

(click me below)

[![crawler](https://i.vimeocdn.com/video/569757392_400x300.png)](https://vimeo.com/165810300 "crawler")

## Required Software

* Homebrew 0.95+
* Ruby 2.2+
* Rubygems 2.1+
* Redis 3.0+
* PhantomJS 2.1+

## Installation (Mac)

Feel free to email me at cnharris@gmail.com with any issues and/or a detailed setup for another platform.  

### 1. Install Homebrew:

	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew update

### 2. Install Ruby (if not already at 2.2+), Redis, and PhantomJS:

	brew install ruby22 
	brew install redis
	brew install phantomjs

### 3. Clone git repository:

	git clone https://github.com/cnharris10/jchallenge ~/
	cd ~/jchallenge

#### 4. Update rubygems, install bundler, and install gems
	
	gem update --system
	gem install bundler
	bundler

### 5. Start Redis (in background):

	redis-server --port 6379 &

### 6. Start resque workers:

	ruby src/workers.rb start
	
*Optional: Tail the resque log as well.*
	
	ruby src/workers.rb start; tail -f logs/resque.log

### 7. Run crawler with host

	ruby find_email_addresses.rb <host>
	
	ex: ruby find_email_addresses.rb cnn.com
	

## Testing

Unit tests for each significant crawler operation.

**Note: Redis server must be running on port 6379**

	cd ~/jchallenge
	rspec tests
	
*Unit Tests output:*

	Crawler::Page
	  #initialize
	    returns an instance with a valid url
	    returns a nil url if invalid
	  #html
	    makes a network call to a valid url
	  #structured_html
	    returns a Nokogiri-parsed structure
	  #is_related_to?
	    returns true if the page supplied is child
	    returns false if the page supplied is not a child
	
	Crawler::Url
	  #initialize
	    returns an instance with a valid https url
	    returns an instance with a valid http url
	    raises an error with an invalid url (http & https)
	  http?
	    should return a verified http host
	    should return nil for an unverified http host
	  https?
	    should return a verified https host
	    should return nil for an unverified https host
	  #sanitize_url
	    returns an absolute url from url: //google.com/
	    returns an absolute url from url: /a/b/c
	    returns an absolute url from url: http://www.google.com/
	  #validate
	    returns true with a valid url
	    returns false with an invalid url
	  #split_and_construct_url
	    returns a URI
	    returns nil with a bad URI
	
	Crawler::Crawl
	  #fetch_html
	    should fetch nothing with a blank page
	    should fetch html
	  #enqueues_subpage
	    enqueues a subpage to be crawled when it's link is found for the first time
	    does not enqueue a subpage to be crawled if it has already been crawled
	
	Crawler::Email
	  #parse_html
	    returns nil for a blank page
	    returns a new crawler page
	
	Finished in 0.04 seconds (files took 0.31691 seconds to load)
	26 examples, 0 failures
	
## Future Considerations

### Crawler:
* Bolster email regex accuracy by taking into account common string delimiters (",',=,<space>). Current regex is prone to including urls with an unescaped '@' sign.
* Incorporate a pool of delayed jobs to better reutilize a set amount of resources
* Allow crawler to be run on multiple browsers.
* Utilize Redis/Resque to run multiple crawlers at once (i.e. cnn.com and mit.edu together)

### Testing:
* Incorporate E2E tests with static HTML sources to ensure that the crawler is finding all possible links/emails.  Unit testing on a small script should be mostly sufficient though.
* Include code coverage statistics
	
	
