require 'evt'
# require_relative 'select_scheduler'

puts "Using Backend: #{Evt::Scheduler.backend}"
Thread.current.scheduler = Evt::Scheduler.new

@server = Socket.new Socket::AF_INET, Socket::SOCK_STREAM
@server.bind Addrinfo.tcp '127.0.0.1', 3002
@server.listen Socket::SOMAXCONN
@scheduler = Thread.current.scheduler

def handle_socket(socket)
  line = socket.gets
  until line == "\r\n" || line.nil?
    line = socket.gets
  end
  socket.write("HTTP/1.1 200 OK\r\nContent-Length: 0\r\n\r\n")
  socket.close
end

Fiber.new(blocking: false) do
  while true
    socket, addr = @server.accept
    Fiber.new(blocking: false) do
      handle_socket(socket)
    end.resume
  end
end.resume

@scheduler.run
