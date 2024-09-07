# wait-for-redis.rb
require 'redis'
require 'timeout'

begin
  Timeout.timeout(10) do
    loop do
      begin
        redis = Redis.new(url: ENV['REDIS_URL'] || 'redis://redis:6379/0')
        redis.ping
        puts "Redis is ready!"
        break
      rescue StandardError => e
        puts "Waiting for Redis... #{e.message}"
        sleep 1
      end
    end
  end
rescue Timeout::Error
  puts "Redis did not respond in time."
  exit 1
end

exec("bundle exec sidekiq")