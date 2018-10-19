require 'nokogiri'

namespace :wordpress_import do |args|

  desc "Import a XML Wordpress Export into FrancisCMS"
  task :import => :environment do

    file = './lib/tasks/cedricio.wordpress.2018-10-18.xml'

    puts "reading & parsing file"
    xml = File.open(file) { |f| Nokogiri::XML(f) }

    puts "loop through items"
    wp_post_types = xml.xpath('//rss/channel/item').map{|i| i.css('category[domain="kind"]').first.try(:attributes).try(:[], 'nicename').try(:value)}.uniq
    # wp_post_types = [nil, "aside", "article", "repost", "note", "reply", "like"]

    for item in xml.xpath('//rss/channel/item')
      kind = item.css('category[domain="kind"]').first.try(:attributes).try(:[], 'nicename').try(:value)
      status = item.xpath('wp:status').first.content
      if status == 'publish'
        wp_post_types.push(item.xpath('wp:post_type').first.content) unless wp_post_types.include?(item.xpath('wp:post_type').first.content)
        attributes = {}
        attributes[:title] = item.css('title').first.content
        attributes[:slug] = item.css('link').first.content.gsub("https://cedric.io/", "")
        attributes[:body] = item.xpath('content:encoded').first.content
        attributes[:excerpt] = item.xpath('excerpt:encoded').first.content
        attributes[:published_at] = item.xpath('wp:post_date').first.content
        attributes[:created_at] = item.xpath('wp:post_date').first.content
        attributes[:updated_at] = item.xpath('wp:post_date').first.content

        # regexp : /a:[0-9]:{(i:[0-9]{1};s:[0-9]{2,3}:\"(http(s):\/\/.*)";)+}/

        for meta in item.xpath('wp:postmeta')
          if meta.xpath('wp:meta_key').first.content == "mf2_syndication"
            puts meta.xpath('wp:meta_value').first.content
          end
        end
        # puts kind.inspect
        # puts attributes.inspect
        FrancisCms::Post.new(attributes).save
      end
    end

    puts wp_post_types.inspect

  end

end