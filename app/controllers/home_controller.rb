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
    radius = {}
    #min_radius = 0.25
    #max_radius = 1

    data = YAML.load_file "#{Rails.root}/public/sites_data.yml"

    #population = []
    #data.each do |site, site_data|
     # population << (site_data["count"] rescue 0)
    #end
    #population = population.compact
    connections = {}
    durations = {}

    data.each do |site, site_data|
			#next if site_data["#{params[:prefix]}ping"].blank?
      connections["#{site}"] = site_data["#{params[:prefix]}ping"] rescue false
      durations["#{site}"] = ((Time.now - site_data["#{params[:prefix]}ping_timestamp"].to_time)/60).round.to_s rescue nil

      count = (site_data["count"] rescue 0).to_f
      r = Math.sqrt(count)*(1/Math.sqrt(1600))
      #r = ((population.percentile_rank(count)/100)*(max_radius - min_radius) + min_radius).round(2)
      radius["#{site}"] = [r, count]

    end

    render :text => [connections, durations, radius].to_json
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
    radius = {}

    data = YAML.load_file "#{Rails.root}/public/sites_data.yml"
    connections = {}
    births = {}
    new_births = {}
    deaths = {}
    new_deaths = {}

    #population = []
    #data.each do |site, site_data|
    #  population << (site_data["count"] rescue 0)
    #end

    #min_radius = 0.25
    #max_radius = 1

    data.each do |site, site_data|

      count = (site_data["count"] rescue 0).to_f
      #mean = (0.5*(max_radius - min_radius) + min_radius).round(2)
      #r = ((population.percentile_rank(count)/100)*(max_radius - min_radius) + min_radius).round(2)
      r = Math.sqrt(count)*(1/Math.sqrt(1600))
      radius["#{site}"] = [r, count]

      births["#{site}"] = site_data['births']
      new_births["#{site}"] = site_data['new_births']
      deaths["#{site}"] = site_data['deaths']
      new_deaths["#{site}"] = site_data['new_deaths']

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

    end

    render :text => [connections, births, new_births, deaths, new_deaths, radius].to_json
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

  def population
    @result = {}
    data = YAML.load_file "#{Rails.root}/public/sites_data.yml"
    data.each do |site, site_data|
      @result["#{site}"]= site_data["count"].to_i rescue 0
    end
    @result = @result.sort_by{|k, v| v}.reverse
  end

end
