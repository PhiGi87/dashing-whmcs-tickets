#!/usr/bin/env ruby
require 'net/http'
require 'json'

# your whmcs url
whmcsurl = 'https://yourdomain.com/whmcs'
#configuration
username = 'dashboard'
#this is the password hashed with md5
password = 'verystrangepassword'
#this is the accesskey from your whmcs
accesskey = '123456'

## Here, no Changes Please!
SCHEDULER.every '1m', :first_in => 0 do |job|
  #whmcs
  uri = URI("{whmcsurl}/includes/api.php")
  params = {accesskey: accesskey, username: username, password: password, action: 'gettickets', responsetype: 'json', status: "Open"}
  uri.query = URI.encode_www_form(params)

  Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
    request = Net::HTTP::Get.new uri.request_uri
    #request.set_form_data(params)
    response = http.request request # Net::HTTPResponse object
    if response.code != "200"
      puts "whmcs error (status-code: #{response.code})\n#{response.body}"
    else
      data = JSON.parse(response.body)
      #puts "WHMCS active tickets: #{data['totalresults']}"
      send_event('tickets', current: data['totalresults'])
    end
  end

end