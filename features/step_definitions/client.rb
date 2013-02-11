def client_variable_name(client_name)
  var = '@' + [
    client_name,
    'client',
  ].compact.map(&:strip).join('_')
end

def set_client(client_name, client)
  instance_variable_set client_variable_name(client_name), client
end

def client(client_name = nil)
  instance_variable_get(client_variable_name(client_name))
end
