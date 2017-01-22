class ScraperController < ApplicationController
  def index
    @areas = Scraper.scrape_areas('https://www.mountainproject.com/v/north-san-diego-county/111860919')
  end
end
