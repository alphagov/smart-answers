# optional:
# REGIONAL_FILTER = ';ga:region==Wales,ga:region==England'
REGIONAL_FILTER = ''

namespace :analytics do
  desc 'Uses Google Analytics to generate a Graphviz flowchart of the usage of a specific Smart Answer.'
  task :analyse, [:smart_answer_name] => [:environment] do |t, args|
    Bundler.require :analytics, :default

    if args[:smart_answer_name].blank?
      puts "This task must be run with the name of a smart answer as parameter, eg: rake analytics:analyse[student-finance-calculator]"
      exit
    end

    begin
      config = YAML.load_file(File.join(ENV['HOME'], ".google-api.yaml"))
    rescue Errno::ENOENT
      puts <<EOF
To run this task you need valid Google API credentials for the OAuth 2
interface to Google Analytics.

Visit the Google API Console at this URL:
https://code.google.com/apis/console/

Generate a client ID and secret for an "installed application" using the API
Access tab. Then use them to run this command:

bundle exec google-api oauth-2-login --scope https://www.googleapis.com/auth/analytics.readonly --client-id client-id@goes.here --client-secret secret-goes-here

This will generate $HOME/.google-api.yaml allowing this rake task to run.

EOF
      exit
    end

    client = Google::APIClient.new
    client.authorization.client_id = config['client_id']
    client.authorization.client_secret = config['client_secret']
    client.authorization.scope = config['scope']
    client.authorization.redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
    client.authorization.update_token!({"access_token" => config['access_token'], "refresh_token" => config['request_token']})
    analytics = client.discovered_api("analytics", "v3")

    smart_name = args[:smart_answer_name]
    smart_answer = SmartAnswer::FlowRegistry.new.flows.find { |f| f.name == smart_name }

    input = {"ids" => "ga:53872948", # GDS Google Analytics ID
      "dimensions" => "ga:pagePath,ga:referralPath",
      "metrics" => "ga:pageviews",
      "filters" => "ga:pagePath=~^/#{smart_name}/.*;ga:referralPath==(not set)" + REGIONAL_FILTER,
      "start-date" => "2012-01-01",
      "end-date" => Date.today.to_s,
      "max-results" => "20000"}
    data = JSON.parse(client.execute(analytics.data.ga.get, input).body)
    if !data.has_key?('rows')
      puts data.inspect
      exit
    else
      rows = data['rows']
    end

    stats = {}
    steps = ["begin"] + smart_answer.nodes.map(&:to_s)
    graph = {}

    rows.each do |path, referral, count|
      count = count.to_i

      forwards = true
      if path.match '\?'
        path, querystring = path.split(/\?/)
        if querystring.match "previous_response=(.*)"
          forwards = false
          path += "/" + $1
        end
      end

      path = path.slice(smart_name.length + 2, path.size) # trim off the top-level directory
      path = path.split(/\//)
      path.shift # trim the 'y' at the start

      state = smart_answer.process(path)
      if state.error
        # doesn't count
      else
        if state.path.size == 0
          previous_step = 'begin'
        else
          previous_step = state.path.last.to_s
        end
        step = state.current_node.to_s

        if step != previous_step
          graph[previous_step] = (graph.fetch(previous_step, []) + [step]).uniq
        else
          puts "#{path}: #{state.inspect}"
        end

        if forwards
          stats[step] = stats.fetch(step, 0) + count
        else
          stats[step] = stats.fetch(step, 0) - count
        end
      end
    end

    puts "digraph #{smart_name.tr('-', '_')} {"
    steps.each_with_index do |step|
      if !stats[step].nil?
        puts "\"#{step.to_s.gsub(/[^a-zA-Z_]/, '')}\" [label=\"#{step.to_s.tr('_', ' ')}\\n(#{stats[step]} people get this far)\"];"
      end
    end
    graph.each do |from_node, to_nodes|
      to_nodes.each do |to_node|
        puts "\"#{from_node.to_s.gsub(/[^a-zA-Z_]/, '')}\" -> \"#{to_node.to_s.gsub(/[^a-zA-Z_]/, '')}\";"
      end
    end
    puts "}"
  end
end
