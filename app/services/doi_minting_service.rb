require 'uri'
require 'net/http'
#require 'Base64' # if using custom header authentication

class DoiMintingService
  module AndsResponse
    MINTING_SUCCESS = 'MT001'
    UPDATE_SUCCESS = 'MT002'
    UNAVAILABLE = 'MT005'
  end

  def initialize(format)
    @base_url = ENV['ANDS_URL_BASE']
    @app_id = ENV['ANDS_APP_ID']
    @format = format.to_s
    @shared_secret = ENV['ANDS_SHARED_SECRET']
  end

  def mint_doi(doiable)
    doi_xml = doiable.to_doi_xml
    uri = URI(url_for(:mint))
    # see comment below for alternate authentication method, if sending shared secret in POST is not okay
    uri.query = URI.encode_www_form(app_id: @app_id, shared_secret: @shared_secret, url: doiable.full_path)
    connection = Net::HTTP.new(uri.host, uri.port)
    connection.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/xml"
    # Authentication can instead be via a custom header. e.g.,:
    # headers['Athorization'] = "Basic " + Base64.encode64(@app_id + ':' + @shared_secret)
    request.body = doi_xml
    response = connection.request(request)

    if response.code.to_i >= 200 && response.code.to_i < 300
      content = JSON.parse(response.body)
      if content['response']['responsecode'] == AndsResponse::MINTING_SUCCESS
        doiable.doi = content['response']['doi']
        doiable.save!
        puts "Successfully minted DOI for #{doiable.full_path} => #{doiable.doi}"
      else
        puts "Failed to mint DOI - DOI minting return a bad response: #{content['response']['responsecode']} / #{content['response']['message']}"
        puts content['response']['verbosemessage']
      end
    else
      puts "Failed to mint DOI - Server returned a bad response: #{response.code} / #{response.message}"
    end
  end

  def update_DOI_URL(doi, new_url)
    uri = URI(url_for(:update))
    uri.query = URI.encode_www_form(app_id: @app_id, shared_secret: @shared_secret, url: new_url, doi: doi)
    connection = Net::HTTP.new(uri.host, uri.port)
    connection.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/xml"
    request.body = doi_xml
    response = connection.request(request)
    if response.code.to_i >= 200 && response.code.to_i < 300
      content = JSON.parse(response.body)
      if content['response']['responsecode'] == AndsResponse::UPDATE_SUCCESS
        puts "Successfully replaced URL for DOI #{doi} => #{new_url}"
      else
        puts "Failed to replace url for existing DOI:#{doi} - Server returned a bad response: #{content['response']['responsecode']} / #{content['response']['message']}"
        puts content['response']['verbosemessage']
      end
    else
      puts "Failed to replace url for DOI:#{doi} - Server returned a bad response: #{response.code} / #{response.message}"
    end
  end
  
  private

  def url_for(action)
    "#{@base_url}/#{action}.#{@format}/"
  end

end

=begin
# json response structure
{
  "response": {
    "type": "type",
    "responsecode": "code",
    "message": "message",
    "doi": "doi",
    "url": "url",
    "app_id": "app_id",
    "verbosemessage": "verbosemessage"
  }
}
=end
