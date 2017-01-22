class Scraper < ApplicationRecord
  class << self
    def scrape_areas(mp_area_url, agent = Mechanize.new)
      page  = agent.get(mp_area_url)

      ## SAVE INFORMATION ABOUT INPUT AREA HERE

      area_links = page.search('#viewerLeftNavColContent .roundedTop div a[target=_top]')
      # area_links = page.links_with(href: /\/v\/+.*/)

      if area_links.length > 0
        # We are in an area with sub-areas,
        # SO CLICK LINKS, and recursively call this function (with agent context) on it to Save Area info
        area_links.each do |area_link|
          p area_link.attribute('href').value
        end
      else
        climbs_links = page.search('#leftNavRoutes tr td a')
        climbs_links.each do |climb_link|
          p climb_link.attribute('href').value
        end
      end

      ## Save information about TOP level area(inputted) into Areas
      # with links from page, for each AREA LINK
    end

    def scrape_climb(mp_climb_url)

    end
  end
end