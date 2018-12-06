require 'nokogiri'
require 'php_serialize'

namespace :wordpress_import do |args|

  desc "Import a XML Wordpress Export into FrancisCMS"
  task :import => :environment do

    file = './lib/tasks/cedricio.wordpress.2018-10-18.xml'

    puts "reading & parsing file"
    xml = File.open(file) { |f| Nokogiri::XML(f) }

    puts "loop through items"
    wp_post_types = xml.xpath('//rss/channel/item').map{|i| i.css('category[domain="kind"]').first.try(:attributes).try(:[], 'nicename').try(:value)}.uniq
    # wp_post_types = [nil, "note", "checkin", "read", "photo", "like", "reply", "bookmark", "rsvp", "article", "quote", "repost", "aside", "page", "post"]

    for item in xml.xpath('//rss/channel/item')
      kind = item.css('category[domain="kind"]').first.try(:attributes).try(:[], 'nicename').try(:value)
      status = item.xpath('wp:status').first.content
      if status == 'publish'
        wp_post_types.push(item.xpath('wp:post_type').first.content) unless wp_post_types.include?(item.xpath('wp:post_type').first.content)
        attributes = {}
        case kind
        when "bookmark"
          for meta in item.xpath('wp:postmeta')
            if meta.xpath('wp:meta_key').first.content == "mf2_bookmark-of"
              data = PHP.unserialize meta.xpath('wp:meta_value').first.content
              data = data.first if data.is_a? Array
              if data.key?('properties')
                link_name = data["properties"]["name"]
                link_url = data["properties"]["url"]
              else
                link_name = data["name"]
                link_url = data["url"]
              end
              puts "---"
              link_url = link_url.first if link_url.is_a? Array
              link_name = link_name.first if link_name.is_a? Array
              puts "url : #{link_url}"
              puts "title : #{link_name}"
              attributes[:url] = link_url
              attributes[:title] = link_name
              attributes[:body] = link_url
            end
          end
          attributes[:tag_list] = ""
          attributes[:published_at] = item.xpath('wp:post_date').first.content
          attributes[:created_at] = item.xpath('wp:post_date').first.content
          attributes[:updated_at] = item.xpath('wp:post_date').first.content 
          object_instance = FrancisCms::Link
        
        when "note"
          attributes[:slug] = item.css('link').first.content.gsub("https://cedric.io/", "")
          attributes[:body] = item.xpath('content:encoded').first.content
          attributes[:tag_list] = ""
          attributes[:excerpt] = item.xpath('excerpt:encoded').first.content
          attributes[:published_at] = item.xpath('wp:post_date').first.content
          attributes[:created_at] = item.xpath('wp:post_date').first.content
          attributes[:updated_at] = item.xpath('wp:post_date').first.content
          object_instance = FrancisCms::Note
        else
          puts kind.inspect
          # attributes[:title] = item.css('title').first.content
          # attributes[:slug] = item.css('link').first.content.gsub("https://cedric.io/", "")
          # attributes[:body] = item.xpath('content:encoded').first.content
          # attributes[:tag_list] = ""
          # attributes[:excerpt] = item.xpath('excerpt:encoded').first.content
          # attributes[:published_at] = item.xpath('wp:post_date').first.content
          # attributes[:created_at] = item.xpath('wp:post_date').first.content
          # attributes[:updated_at] = item.xpath('wp:post_date').first.content
          # object_instance = FrancisCms::Post
        end
        
        if object_instance
          puts "saving #{object_instance}", attributes
          object = object_instance.new(attributes)
          object.save
          if object.errors.any?
           raise object.errors.inspect
          end

          puts "cheking metadata"
          for meta in item.xpath('wp:postmeta')
            if meta.xpath('wp:meta_key').first.content == "mf2_syndication"
              sources = PHP.unserialize meta.xpath('wp:meta_value').first.content
              if sources.any?
                if object.respond_to?(:slug)
                  puts sources.inspect
                  puts "#{FrancisCms.configuration.site_url}#{object.slug}"
                  for source in sources
                    FrancisCms::Webmention.new(
                      source: source,
                      target: "#{FrancisCms.configuration.site_url}#{object.slug}",
                      created_at: object.created_at
                    ).save!
                  end
                end
              end
            end
          end
        end
      end
    end
  end

end