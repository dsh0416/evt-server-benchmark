require 'evt'

puts "Using Backend: #{Evt::Scheduler.backend}"
@scheduler = Evt::Scheduler.new
Fiber.set_scheduler @scheduler

@server = Socket.new Socket::AF_INET, Socket::SOCK_STREAM
@server.bind Addrinfo.tcp '127.0.0.1', 3002
@server.listen Socket::SOMAXCONN

def handle_socket(socket)
  line = socket.gets
  until line == "\r\n" || line.nil?
    line = socket.gets
  end
  socket.write("HTTP/1.1 200 OK\r\nContent-Length: 0\r\n\r\n")
  socket.close
end

Fiber.schedule do
  while true
    socket, addr = @server.accept
    Fiber.schedule do
      handle_socket(socket)
    end
  end
end

@scheduler.run
