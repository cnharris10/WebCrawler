require "redis"
require_relative "./config"

REDIS_CLIENT = Redis.new(:host => Crawler::Redis::HOST, :port => Crawler::Redis::PORT)
REDIS_CLIENT.del(Crawler::Queues::URLS)
REDIS_CLIENT.del(Crawler::Queues::EMAILS)
