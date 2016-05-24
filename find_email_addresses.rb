require "socket"
require "resque"
require "logger"
require "byebug"

require_relative "src/crawler/url"
require_relative "src/crawler/logger"
require_relative "src/crawler/redis"
require_relative "src/tasks/crawl"

host = ARGV[0]

# Validate that host exists at http or https
initial_page = Crawler::Page.new("http://#{host}") || Crawler::Page.new("https://#{host}")

# Queue host url
Resque.enqueue(Crawler::Crawl, initial_page.url.to_s) unless initial_page.nil?

# List emails found every 2 seconds
while true do
  system("clear")
  puts "Found these email addresses:"
  emails = REDIS_CLIENT.smembers("emails")
  puts "#{emails.join("\n")}" if emails.count > 0
  puts "..."  
  sleep(2)
end