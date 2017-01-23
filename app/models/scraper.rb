class Scraper < ApplicationRecord
  class << self
    def scrape_areas(mp_area_url, agent=Mechanize.new, parent_id=1)
      page = agent.get(mp_area_url)

      area_name  = page.search('.rspCol .rounded .rspCol h1 em')
                       .children.first.content
                       .gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
      area_coord = page.search('.rspCol .rounded .rspCol table tr:nth-child(2) td:nth-child(2)')
                       .children.first.content
                       .gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
      area_desc  = page.search('h3.dkorange + div').children[1].content
      area_gt    = page.search('h3.dkorange + div').children[4].content

      area_info = {
        name:        area_name,
        coord:       area_coord,
        description: area_desc,
        get_there:   area_gt,
        parent_id:   parent_id,
        href:        mp_area_url
      }

      scraped_area = Area.new(area_info)
      scraped_area.save

      area_links = page.search('#viewerLeftNavColContent .roundedTop div a[target=_top]')
      # area_links = page.links_with(href: /\/v\/+.*/)

      if !area_links.empty?
        # We are in an area with sub-areas,
        # SO CLICK LINKS, and recursively call this function (with agent context) on it to Save Area info
        area_links.each do |area_link|
          # p area_link.attribute('href').value
          built_url = 'https://www.mountainproject.com' + area_link.attribute('href').value
          scrape_areas(built_url, agent, scraped_area.id)
        end
      else
        # We are in an area that has CLIMBS (NO sub-areas)

        climbs_links = page.search('#leftNavRoutes tr td a')
        climbs_links.each do |climb_link|
          # p climb_link.attribute('href').value
          built_url = 'https://www.mountainproject.com' + climb_link.attribute('href').value
          scrape_climb(built_url, agent, scraped_area.id)
        end
      end

      area_info
    end

    def scrape_climb(mp_climb_url, agent=Mechanize.new, area_id=1)
      page = agent.get(mp_climb_url)

      climb_name      = page.search('.rspCol h1.dkorange em span[itemprop=itemreviewed]').children.first.content

      if page.search('.rateYDS').children[2]
        climb_grade     = page.search('.rateYDS').children[2].content.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
      elsif page.search('.rateHueco').children[2]
        climb_grade     = page.search('.rateHueco').children[2].content.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
      end
      
      if page.search('.rspCol span table tr:first-child td:nth-child(2)').children.first
        climb_type       = page.search('.rspCol span table tr:first-child td:nth-child(2)').children.first.content
      else
        climb_type = nil
      end

      if page.search('.rspCol span table tr:nth-child(3) td:nth-child(2)').children[1]
        climb_fa         = page.search('.rspCol span table tr:nth-child(3) td:nth-child(2)').children[1].content
      else
        climb_fa = nil
      end

      if page.search('h3.dkorange + div').children[1]
        climb_desc       = page.search('h3.dkorange + div').children[1].content
      else
        climb_desc = nil
      end

      if page.search('h3.dkorange + div').children[4]
        climb_location   = page.search('h3.dkorange + div').children[4].content
      else
        climb_location = nil
      end

      if page.search('h3.dkorange + div').children[7]
        climb_protection = page.search('h3.dkorange + div').children[7].content.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
      else
        climb_protection = nil
      end

      climb_info = {
        name:        climb_name,
        grade:       climb_grade,
        style:       climb_type,
        fa:          climb_fa,
        description: climb_desc,
        location:    climb_location,
        protection:  climb_protection,
        area_id:     area_id,
        href:        mp_climb_url
      }

      scraped_climb = Climb.new(climb_info)
      scraped_climb.save

      climb_info
    end
  end
end
