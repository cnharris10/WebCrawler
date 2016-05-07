require "logger"
require_relative "./config"

ScraperLogger = Logger.new(Scraper::LOGFILE)
ScraperLogger.level = Logger::DEBUG