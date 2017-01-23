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

      climb_name = page.search('.rspCol h1.dkorange em span[itemprop=itemreviewed]').children.first.content

      climb_grade = if res = page.search('.rateYDS').children[2]
                      res.content.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
                    elsif res = page.search('.rateHueco').children[2]
                      res.content.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
                    end

      climb_type = if res = page.search('.rspCol span table tr:first-child td:nth-child(2)').children.first
                     page.search('.rspCol span table tr:first-child td:nth-child(2)').children.first.content
                   end

      climb_fa = if res = page.search('.rspCol span table tr:nth-child(3) td:nth-child(2)').children[1]
                   res.content
                 end

      climb_desc = if res = page.search('h3.dkorange + div').children[1]
                     res.content
                   end

      climb_location = if res = page.search('h3.dkorange + div').children[4]
                         res.content
                       end

      climb_protection = if res = page.search('h3.dkorange + div').children[7]
                           res.content.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
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
