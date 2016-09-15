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
			#next if site_data["#{params[:prefix]}ping"].blank?
      connections["#{site}"] = site_data["#{params[:prefix]}ping"] rescue false
      durations["#{site}"] = ((Time.now - site_data["#{params[:prefix]}ping_timestamp"].to_time)/60).round.to_s rescue nil
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
          last_seen = "#{days_diff} days ago"
        elsif hrs_diff > 0
          last_seen = "#{hrs_diff} hr ago"
        elsif min_diff > 0
          last_seen = "#{min_diff} min ago"
        else
          last_seen = "#{sec_diff} sec ago"
        end

        connections["#{site}"] = last_seen
    end

    render :text => [connections].to_json
  end

 def connection_lastseennews_status
    data = YAML.load_file "#{Rails.root}/public/sites_data.yml"
    connections = {}
    births = {}
    new_births = {}
    deaths = {}
    new_deaths = {}
    data.each do |site, site_data|
		  next if site_data['news_ping_timestamp'].blank?
			t = site_data['news_ping_timestamp']
		  hrs_diff = ((Time.now - t.to_time)/(60*60)).to_i
		 
			#0 in 48 hours
			#1 In 48hrs to 3 days
			#2 In 3 days
		  if hrs_diff <= 48
		      index = 2
		  elsif hrs_diff <= 72
		      index = 1
		  else
					index = 0
			end

      connections["#{site}"] = index
      births["#{site}"] = site_data['births']
      new_births["#{site}"] = site_data['new_births']
      deaths["#{site}"] = site_data['deaths']
      new_deaths["#{site}"] = site_data['new_deaths']
    end

    render :text => [connections, births, new_births, deaths, new_deaths].to_json
  end
		
	def births_deaths_stats
		stats = {}
		data = YAML.load_file "#{Rails.root}/public/sites_data.yml"
		total_births = 0
		total_deaths = 0
    data.each do |site, site_data|
				total_births += site_data["births"].to_i
				total_deaths += site_data["deaths"].to_i

				stats["#{site}"] = {}
				stats["#{site}"]['births'] = site_data["births"]
				stats["#{site}"]['deaths'] = site_data["deaths"]
				stats["#{site}"]['new_births'] = site_data["new_births"]
				stats["#{site}"]['new_deaths'] = site_data["new_deaths"]
		end

		stats["births"] = total_births
		stats["deaths"] = total_deaths

		render :text => stats.to_json
	end

	def news_data 
		result = {}
		render :text => result.to_json
	end 

	def census_data 
		result = {}
		render :text => result.to_json
	end

end
