require "socket"
require "resque"
require "logger"
require "byebug"

require_relative "src/scraper/url"
require_relative "src/scraper/logger"
require_relative "src/scraper/redis"
require_relative "src/tasks/scrape"

# Validate that hosts exists
host = ARGV[0]
initial_page = Scraper::Page.new("http://#{host}") || Scraper::Page.new("https://#{host}")
Resque.enqueue(Scraper::Scrape, initial_page.url.to_s) unless initial_page.nil?

while true do
  system("clear")
  puts "Found these email addresses:"
  emails = REDIS_CLIENT.smembers("emails")
  puts "#{emails.join("\n")}" if emails.count > 0
  puts "..."
  sleep(2)
end


#DEBUG
#Scraper::Scrape.perform(host) unless page.nil?
#html = open("http://www.attend.com").read
#Scraper::Email.perform(html)