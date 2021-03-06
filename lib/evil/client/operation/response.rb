class Evil::Client::Operation
  require_relative "response_error"
  require_relative "unexpected_response_error"

  # Processes rack responses using an operation's schema
  class Response
    extend Dry::Initializer::Mixin
    param :schema

    # Processes rack responses returned by [Dry::Cluent::Connection]
    #
    # @param  [Array] array Rack-compatible array of response data
    # @return [Object]
    #
    # @raise [Evil::Client::ResponseError] when needed by the schema
    # @raise [Evil::Client::UnexpectedResponseError]
    #   when a response cannot be processed
    #
    def handle(response)
      status, _, body = response
      body = body.any? ? body.join("\n") : nil

      handlers(status).each do |handler|
        data = handler[:coercer][body] rescue next
        raise ResponseError.new(schema, status, data) if handler[:raise]
        return data
      end

      raise UnexpectedResponseError.new(schema, status, body)
    end

    private

    def handlers(status)
      list = schema[:responses].values.select { |item| item[:status] == status }
      list.reject { |item| item[:raise] } + list.select { |item| item[:raise] }
    end
  end
end
