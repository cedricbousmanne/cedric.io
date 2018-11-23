require 'nokogiri'
require 'php_serialize'

namespace :wordpress_import do |args|

  desc "Import a XML Wordpress Export into FrancisCMS"
  task :import => :environment do

    file = './lib/tasks/cedricio.wordpress.2018-11-20.xml'

    puts "cleaning all data"
    FrancisCms::Link.destroy_all
    FrancisCms::Note.destroy_all
    FrancisCms::Post.destroy_all
    FrancisCms::Checkin.destroy_all
    FrancisCms::Webmention.destroy_all

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
              begin
                data = PHP.unserialize meta.xpath('wp:meta_value').first.content
                data = data.first if data.is_a? Array
                if data.is_a? String
                  link_url = data
                elsif data.key?('properties')
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
              rescue

              end
            end
          end
          attributes[:tag_list] = ""
          attributes[:published_at] = item.xpath('wp:post_date').first.content
          attributes[:created_at] = item.xpath('wp:post_date').first.content
          attributes[:updated_at] = item.xpath('wp:post_date').first.content 
          object_instance = FrancisCms::Link
        
        when "note"
          attributes[:title] = item.css('title').first.content
          attributes[:slug] = item.css('link').first.content.gsub("https://cedric.io/", "")
          attributes[:body] = item.xpath('content:encoded').first.content
          attributes[:tag_list] = ""
          attributes[:excerpt] = item.xpath('excerpt:encoded').first.content
          attributes[:published_at] = item.xpath('wp:post_date').first.content
          attributes[:created_at] = item.xpath('wp:post_date').first.content
          attributes[:updated_at] = item.xpath('wp:post_date').first.content
          object_instance = FrancisCms::Note
        when "article"
          attributes[:title] = item.css('title').first.content
          attributes[:slug] = item.css('link').first.content.gsub("https://cedric.io/", "")
          attributes[:body] = item.xpath('content:encoded').first.content
          attributes[:tag_list] = ""
          attributes[:excerpt] = item.xpath('excerpt:encoded').first.content
          attributes[:published_at] = item.xpath('wp:post_date').first.content
          attributes[:created_at] = item.xpath('wp:post_date').first.content
          attributes[:updated_at] = item.xpath('wp:post_date').first.content
          object_instance = FrancisCms::Post
        when "repost"
          puts "#{kind} is not implemented yet"
          next
        when "like"
          puts "#{kind} is not implemented yet"
          next
        when "checkin"
          puts "#{kind} is not implemented yet"
          for meta in item.xpath('wp:postmeta')
            if meta.xpath('wp:meta_key').first.content == "mf2_location"
              location = PHP.unserialize meta.xpath('wp:meta_value').first.content
            end
          end

          geo_latitude, geo_longitude = location.first.gsub('geo:', '').split(',')

          attributes[:title] = item.css('title').first.content
          attributes[:body] = item.xpath('content:encoded').first.content
          attributes[:tag_list] = ""
          attributes[:latitude] = geo_latitude
          attributes[:longitude] = geo_longitude
          attributes[:published_at] = item.xpath('wp:post_date').first.content
          attributes[:created_at] = item.xpath('wp:post_date').first.content
          attributes[:updated_at] = item.xpath('wp:post_date').first.content
          object_instance = FrancisCms::Checkin
        when "rsvp"
          puts "#{kind} is not implemented yet"
          next
        when "photo"
          puts "#{kind} is not implemented yet"
          next
        when "quote"
          puts "#{kind} is not implemented yet"
          next
        when "read"
          puts "#{kind} is not implemented yet"
          next
        when nil
          puts "nil kind detected"
          puts item.inspect
          puts "---"
          next
        else
          puts kind.inspect
          next
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
            puts attributes.inspect
            puts object.errors.inspect
            next
          end

          puts "cheking metadata"
          for meta in item.xpath('wp:postmeta')
            if meta.xpath('wp:meta_key').first.content == "mf2_syndication"
              targets = PHP.unserialize meta.xpath('wp:meta_value').first.content
              if targets.any?
                if object.respond_to?(:slug)
                  for target in targets
                    puts "webmention from "+"#{send(object.class.to_s.downcase.gsub('franciscms::', '')+'_path', object)} " + " to " + target
                    webmention = FrancisCms::Webmention.new(
                      source: "#{send(object.class.to_s.downcase.gsub('franciscms::', '')+'_path', object)}",
                      target: target,
                      created_at: object.created_at
                    )
                    webmention.save
                    webmention.verify
                    if webmention.errors.any?
                     raise object.errors.inspect
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

end