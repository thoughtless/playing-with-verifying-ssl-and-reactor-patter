#!/usr/bin/env ruby


require 'cool.io/http'

class Coolio::Http
  def self.verify_ssl_request opts={}, &block

    method  = opts[:method]  || opts['method']  || :get
    url     = opts[:url]     || opts['url']
    payload = opts[:payload] || opts['payload'] || {}
    headers = opts[:headers] || opts['headers'] || {}
    query   = opts[:query]   || opts['query']   || {}
    loop    = opts[:loop]    || opts['loop']    || Coolio::Loop.default

    uri  = URI.parse(url)
    path = if uri.path.strip.empty? then '/' else uri.path end
    q    = (uri.query || '').split('&').inject({}){ |r, i|
             k, v = i.split('=')
             r[k] = v
             r}.merge(query.inject({}){ |r, (k, v)| r[k.to_s] = v.to_s; r })
    p    = Payload.generate(payload)

    http = connect(uri.host, uri.port, uri.scheme.downcase == 'https').attach(loop)

    http.ssl_context.set_params(
        :verify_mode => OpenSSL::SSL::VERIFY_PEER,
        :ca_path     => File.expand_path(File.join(File.dirname(__FILE__), '..', 'certs'))
      )

    http.request(method.to_s.upcase, path, :query => q,
                                        :head  => p.headers.merge(headers),
                                        :body  => p.read, &block)
  end
end

url = 'https://www.yahoo.com'
#url = 'https://www.example.com'
#url = 'https://google.com'
#Coolio::Http.request(:url => url){ |response|
Coolio::Http.verify_ssl_request(:url => url){ |response|
  puts "Response: #{response.body}"
  puts
  puts " Headers: #{response.headers}"
  puts "  Status: #{response.status}"
}

Coolio::Loop.default.run
