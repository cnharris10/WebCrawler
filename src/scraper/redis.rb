require "redis"
require_relative "./config"

REDIS_CLIENT = Redis.new(:host => Scraper::Redis::HOST, :port => Scraper::Redis::PORT)
REDIS_CLIENT.del(Scraper::Queues::URLS)
REDIS_CLIENT.del(Scraper::Queues::EMAILS)
