namespace :dashboard do
  desc "TODO"
  task pull_data: :environment do
    require 'yaml'

    FileUtils.touch("#{Rails.root}/public/sites_data.yml")

    ip = (YAML.load_file "#{Rails.root}/config/application.yml")["#{Rails.env}"]["evr_server"]
    interval = (YAML.load_file "#{Rails.root}/config/application.yml")["#{Rails.env}"]["pull_interval_minutes"]
    interval = interval.to_i * 60
    result = YAML.load_file("#{Rails.root}/public/sites_data.yml") || {}
    result.each do |site, data|
      if result["#{site}"]["ping_timestamp"].blank? || result["#{site}"]["ping_timestamp"].to_date < Date.today
        result["#{site}"]["new_births"] = 0
        result["#{site}"]["births"] = 0

        result["#{site}"]["new_deaths"] = 0
        result["#{site}"]["deaths"] = 0

        result["#{site}"]["new_count"] = 0
      end
    end
    ip = "#{ip}/api/dashboard"
    rst = JSON.parse(RestClient.get(ip)) #rescue {}
    online = rst['online']
    news_online = rst['news_online']
    rbirths = rst['births'] || {}
    rdeaths = rst['deaths'] || {}
    rcounts = rst['counts'] || {}

    online.each do |site, lastseen|
      puts "EVR #{site}: #{lastseen}"

      result["#{site}"] = {} if result["#{site}"].blank?
      result["#{site}"]["ping"] = interval >= (Time.now - lastseen.to_time)
      result["#{site}"]["ping_timestamp"] = lastseen
    end


    news_online.each do |site, lastseen|
      puts "EVR #{site}: #{lastseen}"
      result["#{site}"] = {} if result["#{site}"].blank?

      result["#{site}"]["news_ping"] = interval >= (Time.now - lastseen.to_time)
      result["#{site}"]["news_ping_timestamp"] = lastseen
    end


    rbirths.each do |site, count|
      result["#{site}"] = {} if result["#{site}"].blank?
      births = count.to_i rescue 0
      new_births = births - (result["#{site}"]["births"].to_i rescue 0)
      result["#{site}"]["new_births"] = new_births
      result["#{site}"]["births"] = births
    end

    rdeaths.each do |site, count|
      result["#{site}"] = {} if result["#{site}"].blank?
      deaths = count.to_i rescue 0
      new_deaths = deaths - (result["#{site}"]["deaths"].to_i rescue 0)
      result["#{site}"]["new_deaths"] = new_deaths
      result["#{site}"]["deaths"] = deaths
    end

    rcounts.each do |site, count|
      result["#{site}"] = {} if result["#{site}"].blank?
      c = count.to_i rescue 0
      new_c = c - (result["#{site}"]["count"].to_i rescue 0)
      result["#{site}"]["new_count"] = new_c
      result["#{site}"]["count"] = c
    end

    file = File.open("#{Rails.root}/public/sites_data.yml", "w")
    file.write result.to_yaml
    file.close
  end

end
