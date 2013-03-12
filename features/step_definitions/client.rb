require 'singleton'

class Clients

  include Singleton

  def initialize
    @clients = {}
  end

  def [](client_name)
    @clients[client_name] ||= TestClient.new
  end

  def close
    @clients.values.each(&:close)
  end

end

def client(client_name = nil)
  client_name ||= 'client'
  Clients.instance[client_name]
end

After do
  Clients.instance.close
end
