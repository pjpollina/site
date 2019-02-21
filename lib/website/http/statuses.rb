# "Enum" of HTTP status codes/messages

module Website
  module HTTP
    STATUSES = {
      200 => 'OK',
      201 => 'Created',
      303 => 'See Other',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not Found',
      409 => 'Conflict'
    }
  end
end
