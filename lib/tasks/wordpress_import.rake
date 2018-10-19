require 'simple-rss'

namespace :wordpress_import do |args|

  desc "Import a XML Wordpress Export into FrancisCMS"
  task :import => :environment do

    url = './lib/tasks/cedricio.wordpress.2018-10-18.xml'

    xml = File.read(url)
    rss = SimpleRSS.parse xml

    for item in rss.items
      puts item.inspect
    end

  end

end