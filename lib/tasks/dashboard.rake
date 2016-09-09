namespace :dashboard do
  desc "TODO"
  task pull_data: :environment do
    require 'yaml'

    FileUtils.touch("#{Rails.root}/public/sites_data.yml")

    ip = (YAML.load_file "#{Rails.root}/config/application.yml")["#{Rails.env}"]["evr_server"]
    interval = 60 #(YAML.load_file "#{Rails.root}/config/application.yml")["#{Rails.env}"]["pull_interval_minutes"]
    interval = interval.to_i * 60
    result = YAML.load_file("#{Rails.root}/public/sites_data.yml") || {}

    ip = "#{ip}/api/dashboard"
    rst = JSON.parse(RestClient.get(ip)) rescue {}
    online = rst['online']

    online.each do |site, lastseen|
      puts "#{site}: #{lastseen}"
      result["#{site}"] = {} if result["#{site}"].blank?
      result["#{site}"]["ping"] = interval >= (Time.now - lastseen.to_time)
      result["#{site}"]["ping_timestamp"] = lastseen

      births = rst["births"][site].to_i rescue 0
      new_births = births - (result["#{site}"]["births"].to_i rescue 0)
      result["#{site}"]["new_births"] = new_births
      result["#{site}"]["births"] = births

      deaths = rst["deaths"][site].to_i rescue 0
      new_deaths = deaths - (result["#{site}"]["deaths"].to_i rescue 0)
      result["#{site}"]["new_deaths"] = new_deaths
      result["#{site}"]["deaths"] = deaths
    end

    file = File.open("#{Rails.root}/public/sites_data.yml", "w")
    file.write result.to_yaml
    file.close
  end

end