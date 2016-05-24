require "resque"

URLS_PID_FILE = "pids/urls.pid"
EMAILS_PID_FILE = "pids/emails.pid"

`touch "#{URLS_PID_FILE}"`
`touch "#{EMAILS_PID_FILE}"`

choice = ARGV[0].downcase.strip

if choice == "start" 
  puts "Starting crawler urls worker queue..."
  `BACKGROUND=1 PIDFILE=#{URLS_PID_FILE} QUEUE=crawl VVERBOSE=1 VERBOSE=1 COUNT=1 rake resque:work`

  puts "Starting emails worker queue..."
  `BACKGROUND=1 PIDFILE=#{EMAILS_PID_FILE} QUEUE=email VVERBOSE=1 VERBOSE=1 COUNT=1 rake resque:work`
elsif choice == "stop"
  puts "Stopping all resque workers..."
  `ps -e -o pid,command | grep [r]esque | awk '{print $1}' | xargs kill -QUIT;`
  `rake resque:clear`
else
  puts "Invalid command. Please choose 'start' or 'stop'"
end