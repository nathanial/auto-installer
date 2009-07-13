require 'logger'

module Logging
  @@logger = Logger.new(STDOUT)
  @@logger.level = Logger::INFO

  def debug(text)
    @@logger.debug(text)
  end

  def warn(text)
    @@logger.warn(text)
  end

  def error(text)
    @@logger.error(text)
  end

  def info(text)
    @@logger.info(text)
  end
end
