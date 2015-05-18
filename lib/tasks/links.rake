require "uri"
require "net/http"

def check_links(links_to_check, broken, file)
  links_to_check.uniq.each { |link|
    begin
      uri = URI.parse(link)
      http = Net::HTTP.new(uri.host, uri.port)

      if link.include?("https")
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      response = http.get(uri.request_uri)

      puts "Checking link: #{link}"
      unless response.class == Net::HTTPOK
        new_hash = { link: link, resp: response.code, file: file }
        if response.code[0] == "3"
          new_hash[:redirect] = response.header['location']
        end
        broken.push(new_hash)
      end
    rescue Exception => e
      # this is here as sometimes we find wrong links through the Regexes
      # dont need to do anything, just capture it to avoid the script breaking
    end
  }
  broken
end

def prefix_link(link)
  unless link.include?("http")
    link = "https://www.gov.uk#{link}"
  end
  link
end

def check_locales_file(contents)
  links_to_check = []
  contents.gsub(/\[(.+)\]\((.+)\)/) { |match|
    link = prefix_link($2.gsub(/ "(.+)"$/,''))
    links_to_check << link
  }
  links_to_check
end

def check_data_file(contents)
  links_to_check = []
  contents.gsub(/: (\/.+)$/) {
    link = prefix_link($1)
    links_to_check << link
  }
  links_to_check
end

namespace :links do
  desc 'Checks all URLs within Smart Answers for errors.'
  task :check, :file do |t, args|
    broken = []
    pwd = Dir.pwd

    # check a single file the user has passed in
    if args.file
      file = args.file
      path = File.expand_path("#{pwd}#{file}")
      puts "Checking #{file}"
      links_to_check = check_locales_file(IO.read(file))
      broken = check_links(links_to_check, broken, file)
    else
      base_path = File.expand_path("#{pwd}/lib")
      Dir.glob("#{base_path}/smart_answer_flows/locales/**/*.yml") { |file|
        puts "Checking #{file}"
        links_to_check = check_locales_file(IO.read(file))
        broken = check_links(links_to_check, broken, file)
      }

      Dir.glob("#{base_path}/data/*.yml") { |file|
        puts "Checking #{file}"
        links_to_check = check_data_file(IO.read(file))
        broken = check_links(links_to_check, broken, file)
      }
    end

    File.open("log/broken_links.log", "w") { |file|
      file.puts broken
    }


    fives = broken.select { |item| item[:resp][0] == "5" }
    four_oh_fours = broken.select { |item| item[:resp][0] == "4" }
    three_oh_threes = broken.select { |item| item[:resp][0] == "3" }

    File.open("log/300_links.log", "w") { |file|
      file.puts three_oh_threes
    }

    File.open("log/404_links.log", "w") { |file|
      file.puts four_oh_fours
    }

    File.open("log/500_links.log", "w") { |file|
      file.puts fives
    }

    if three_oh_threes.length > 0
      puts "Warning: Found links that give a 3XX response. Look in log/300_links.log"
    else
      puts "No 3XX links found"
    end

    if four_oh_fours.length > 0
      puts "Warning: Found 404s. Look in log/404_links.log"
    else
      puts "No 404s found"
    end

    if fives.length > 0
      puts "Warning: Found links that give a 5XX response. Look in log/500_links.log"
    else
      puts "No 5XX links found"
    end
  end
end
