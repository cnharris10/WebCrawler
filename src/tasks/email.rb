require_relative "../crawler/config"
require_relative "../crawler/logger"
require_relative "../crawler/page"

module Crawler
  class Email
    @queue = :email

    def self.perform(html)
      self.parse(html)
    end

    # Add matching emails to Redis
    def self.parse(html)
      return nil if html.nil?
      emails = html.scan(Crawler::EMAIL_REGEX)
      ::CrawlerLogger.info("########## Emails parsed: #{emails.count > 0 ? emails : 0} ##########")
      emails.each do |email|
        REDIS_CLIENT.sadd(Crawler::Queues::EMAILS, email.downcase.strip)
      end
    end 

  end
end