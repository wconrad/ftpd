# frozen_string_literal: true

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
  client_name = client_name.strip
  Clients.instance[client_name]
end
