# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "#{Rails.env}/log/cron_log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
 every 30.minute do
   rake "dashboard:pull_data"
   #command 'rsync -a public/sites_data.yml software:@71.19.156.178:/var/www/EVR_Dashboard/public/'
 end

# Learn more: http://github.com/javan/whenever
