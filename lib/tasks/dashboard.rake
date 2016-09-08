namespace :dashboard do
  desc "TODO"
  task pull_data: :environment do
    require 'yaml'
    require 'net-ping'
    File.open("sites_data.yml", "w") rescue nil

    sites = YAML.load_file "#{Rails.root}/config/site_addresses.yml"
    result = YAML.load_file("#{Rails.root}/public/sites_data.yml")
    sites.each do |site, add|
      ip = add
      check = Net::Ping::External.new(ip)
      rst = check.ping? rescue false
      result = {} if result.blank?
      result["#{site}"] = {} if result["#{site}"].blank?
      result["#{site}"]["ping"] = rst

      result["#{site}"]["ping_timestamp"] = result["#{site}"]["ping"] ?  DateTime.now.to_s(:db) : (result["#{site}"]["ping_timestamp"].to_datetime.to_s(:db) rescue '')

      ip = "http://#{add}/api/dashboard"
      rst = JSON.parse(RestClient.get(ip)) rescue {}
      result["#{site}"]["data"] = rst
    end

    file = File.open("#{Rails.root}/public/sites_data.yml", "w")
    file.write result.to_yaml
  end

end