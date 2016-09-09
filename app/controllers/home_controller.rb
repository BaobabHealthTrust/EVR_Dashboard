class HomeController < ApplicationController
  def home

  end

  def connection_dashboard
    render :layout => false
  end

  def new_births

  end

  def new_deaths

  end

  def connection_status
    data = YAML.load_file "#{Rails.root}/public/sites_data.yml"
    connections = {}
    durations = {}

    data.each do |site, site_data|
      connections["#{site}"] = site_data['ping']
      durations["#{site}"] = ((Time.now - site_data['ping_timestamp'].to_time)/60).round.to_s
    end
    render :text => [connections, durations].to_json
  end

  def connection_lastseen_status
    data = YAML.load_file "#{Rails.root}/public/sites_data.yml"
    connections = {}
    data.each do |site, site_data|
      next if site_data['ping_timestamp'].blank?
      months_diff = ((Time.now - site_data['ping_timestamp'].to_time)/(60*60*24*30)).to_i
      days_diff = ((Time.now - site_data['ping_timestamp'].to_time)/(60*60*24)).to_i
      hrs_diff = ((Time.now - site_data['ping_timestamp'].to_time)/(60*60)).to_i
      min_diff = ((Time.now - site_data['ping_timestamp'].to_time)/(60)).to_i
      sec_diff = (Time.now - site_data['ping_timestamp'].to_time).to_i

      if months_diff > 0
        last_seen = "#{months_diff} months ago"
    elsif days_diff > 0
        last_seen = "#{days_diff / 24} days ago"
      elsif hrs_diff > 0
        last_seen = "#{hrs_diff} hr ago"
      elsif min_diff > 0
        last_seen = "#{min_diff} min ago"
      else
        last_seen = "#{sec_diff} sec ago"
      end

      connections["#{site}"] = last_seen
    end

    render :text => connections.to_json
  end
end
