#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'

module HttpHeaders 
  def initialize
  end

  def post_init
    send_data "GET / HTTP/1.0\n\n"
    @data = ""
  end
  
  def receive_data(data)
    @data << data
  end
  
  def unbind
    puts @data
    
    EventMachine::stop_event_loop
  end
end


#    @ssl_context = OpenSSL::SSL::SSLContext.new
#    @ssl_context.set_params(
#      :verify_mode => OpenSSL::SSL::VERIFY_PEER,
#      :ca_path     => File.expand_path(File.join(File.dirname(__FILE__), '..', 'certs'))
#    )
#    @tcp_client = TCPSocket.new 'www.google.ca', 443
#    @ssl_client = OpenSSL::SSL::SSLSocket.new @tcp_client, @context

#EventMachine::run do
#  #EventMachine::connect 'www.google.ca', 443, HttpHeaders
#  EventMachine::attach @tcp_client, HttpHeaders
#end

#@ssl_client.connect
#
#@ssl_client.puts "GET /\r\n\n"
#puts @ssl_client.gets

# http://www.braintreepayments.com/devblog/sslsocket-verify_mode-doesnt-verify

require 'socket'
require 'openssl'
require 'net/protocol'

def verify_ssl_certificate(preverify_ok, ssl_context)
  if preverify_ok != true || ssl_context.error != 0
    err_msg = "SSL Verification failed -- Preverify: #{preverify_ok}, Error: #{ssl_context.error_string} (#{ssl_context.error})"
    raise OpenSSL::SSL::SSLError.new(err_msg)
  end
  true
end

socket = TCPSocket.new('google.ca', 443)

ssl_context = OpenSSL::SSL::SSLContext.new
ssl_context.verify_mode = OpenSSL::SSL::VERIFY_PEER
ssl_context.verify_callback = proc do |preverify_ok, ssl_context|
  verify_ssl_certificate(preverify_ok, ssl_context)
end
ssl_context.ca_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'certs'))

ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
ssl_socket.sync_close = true
ssl_socket.connect

#ssl_socket.puts("GET / HTTP/1.0")
#ssl_socket.puts("")
#while line = ssl_socket.gets
#  puts line
#end

buffered_io = Net::BufferedIO.new(ssl_socket)


EventMachine::run do
  #EventMachine::connect 'www.google.ca', 443, HttpHeaders
  EventMachine::attach buffered_io, HttpHeaders
end
