class HomeController < ApplicationController
  def home

  end

  def connection_status

    sites = YAML.load_file "#{Rails.root}/config/site_addresses.yml"
    result = {}
    sites.each do |site, ip|
      ip = "http://#{ip}/api/ping"
      rst = RestClient.get(ip) rescue false
      result["#{site}"] = (rst == "Ok") ? true : false
    end

    render :text => result.to_json
  end
end
