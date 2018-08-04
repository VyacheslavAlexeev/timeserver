require 'socket'
require_relative 'app'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: server.rb [options]'

  opts.on('-h', '--host', 'Set server host') do |h|
    options[:host] = h
  end

  opts.on('-p', '--port', 'Set server port') do |p|
    options[:port] = p
  end
end.parse!

DEFAULT_HOST = '127.0.0.1'.freeze
DEFAULT_PORT = 8000

host = options[:host] || DEFAULT_HOST
port = options[:port] || DEFAULT_PORT

server = TCPServer.new(host, port)
puts "Server started on #{host}:#{port}"

app = App.new

# loop infinitely
loop do
  Thread.start(server.accept) do |socket|
    request = socket.gets

    # PARSE REQUEST
    method, full_path = request.split(' ')
    path, query = full_path.split('?')

    # SET ENV AND RUN APP
    status, headers, body = app.call(
      'REQUEST_URI' => full_path,
      'REQUEST_METHOD' => method,
      'REQUEST_PATH' => path,
      'QUERY_STRING' => query
    )

    socket.print "HTTP/1.1 #{status}\r\n"

    headers.each do |key, value|
      socket.print "#{key}: #{value}\r\n"
    end

    socket.print "Content-Length: #{body.map(&:bytesize).sum}\r\n \
                 Connection: close\r\n"

    socket.print "\r\n"

    body.each do |part|
      socket.print part
    end

    socket.close
  end
end

server_thread.join
