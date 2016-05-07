require_relative "../scraper/config"
require_relative "../scraper/logger"
require_relative "../scraper/page"

module Scraper
  class Email
    @queue = :email

    def self.perform(html)
      self.parse_emails(html)
    end

    # Add matching emails to Redis
    def self.parse_emails(html)
      return nil if html.nil?
      html.scan(Scraper::EMAIL_REGEX) do |email|
        REDIS_CLIENT.sadd(Scraper::Queues::EMAILS, email.downcase.strip)
      end
    end 

  end
end