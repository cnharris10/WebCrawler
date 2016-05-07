require "logger"
require_relative "./config"

CrawlerLogger = Logger.new(Crawler::LOGFILE)
CrawlerLogger.level = Logger::DEBUG