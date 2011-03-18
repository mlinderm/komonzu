require 'rexml/document'
require 'rest-client'
require 'uri'
require 'time'
require 'json'
require 'komonzu/version'

# A Ruby class to call the Komonzu REST API. 

class Komonzu::Client

  def self.version
    Komonzu::VERSION
  end

  def self.gem_version_string
    "komonzu-gem/#{version}"
  end

  attr_accessor :host, :user, :password

  def self.auth(user, password, host='komonzu.komonzu.com')
    client = new(user, password, host)
    JSON.parse client.post('/users/sign_in', { :username => user, :password => password }, :accept => 'json').to_s
  end

  def initialize(user, password, host='komonzu.komonzu.com')
    @user = user
    @password = password
    @host = host
  end

	def on_warning(&blk)
    @warning_callback = blk
  end

	##################
		
	def list
		get('/users/edit', :accept => 'html')
	end

	def keys
    #doc = xml get('/user/keys').to_s
    #doc.elements.to_a('//keys/key').map do |key|
      #key.elements['contents'].text
    #end
		[]
  end

	def config_vars(project_name)
    JSON.parse get("/projects/#{project_name}/config_vars", :accept => 'json').to_s
  end

  def add_config_vars(project_name, new_vars)
    post("/projects/#{project_name}/config_vars", new_vars.to_json, :accept => 'json').to_s
  end

  def remove_config_var(project_name, key)
    delete("/projects/#{project_name}/config_vars/#{escape(key)}", :accept => 'json').to_s
  end
	
	##################

  def resource(uri)
    RestClient.proxy = ENV['HTTP_PROXY'] || ENV['http_proxy']
    if uri =~ /^https?/
      RestClient::Resource.new(uri, user, password)
    elsif host =~ /^https?/
      RestClient::Resource.new(host, user, password)[uri]
    else
      RestClient::Resource.new("https://#{host}", user, password)[uri]
    end
  end

  def get(uri, extra_headers={})    # :nodoc:
    process(:get, uri, extra_headers)
  end

  def post(uri, payload="", extra_headers={})    # :nodoc:
    process(:post, uri, extra_headers, payload)
  end

  def put(uri, payload, extra_headers={})    # :nodoc:
    process(:put, uri, extra_headers, payload)
  end

  def delete(uri, extra_headers={})    # :nodoc:
    process(:delete, uri, extra_headers)
  end

  def process(method, uri, extra_headers={}, payload=nil)
    headers  = komonzu_headers.merge(extra_headers)
    args     = [method, payload, headers].compact
    response = resource(uri).send(*args)

    extract_warning(response)
    response
  end

  def extract_warning(response)
    return unless response
    if response.headers[:x_komonzu_warning] && @warning_callback
      warning = response.headers[:x_komonzu_warning]
      @displayed_warnings ||= {}
      unless @displayed_warnings[warning]
        @warning_callback.call(warning)
        @displayed_warnings[warning] = true
      end
    end
  end

  def komonzu_headers   # :nodoc:
    {
      'User-Agent'           => self.class.gem_version_string,
      'X-Ruby-Version'       => RUBY_VERSION,
      'X-Ruby-Platform'      => RUBY_PLATFORM
    }
  end

  def xml(raw)   # :nodoc:
    REXML::Document.new(raw)
  end

  def escape(value)  # :nodoc:
    escaped = URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    escaped.gsub('.', '%2E') # not covered by the previous URI.escape
  end
	
end
