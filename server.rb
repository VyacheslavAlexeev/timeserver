require 'socket'
require_relative 'app'

DEFAULT_HOST = '127.0.0.1'
DEFAULT_PORT = 8000

app = App.new
server_thread = Thread.start do
  server = TCPServer.new(host = DEFAULT_HOST, port = DEFAULT_PORT)

  # loop infinitely
  loop do
    puts "Server started"
    Thread.start(server.accept) do |socket|
      request = socket.gets

      # PARSE REQUEST
      method, full_path = request.split(' ')
      path, query = full_path.split('?')

      puts method
      puts full_path
      puts path
      puts query

      # SET ENV AND RUN APP
      status, headers, body = app.call({
        'REQUEST_URI' => full_path,
        'REQUEST_METHOD' => method,
        'REQUEST_PATH' => path,
        'QUERY_STRING' => query
      })

      socket.print "HTTP/1.1 #{status}\r\n"

      headers.each do |key, value|
        socket.print "#{key}: #{value}\r\n"
      end

      socket.print "Content-Length: #{body.map { |part| part.bytesize }.sum}\r\n" +
                   "Connection: close\r\n"

      socket.print "\r\n"

      body.each do |part|
        socket.print part
      end

      socket.close
    end
  end
end

server_thread.join
