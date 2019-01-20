# Basic path pattern object/parser thing, like in Rails and Sinatra

module Website
  class PathPattern
    SLUG = "[A-Za-z0-9]+(?:[A-Za-z0-9_-]+[A-Za-z0-9]){0,255}"

    attr_reader :regex, :params_base

    def initialize(path)
      regexp_string = "^"
      @params_base = {}
      path.split('/')[1..-1].each_with_index do |param, index|
        regexp_string += '/'
        if(param.start_with?(':'))
          @params_base[index + 1] = param[1..-1].to_sym
          regexp_string += SLUG
        else
          regexp_string += param
        end
      end
      @regex = Regexp.new(regexp_string + "$")
    end

    def match?(path)
      regex.match?(path)
    end

    alias_method(:===, :match?)

    def parse(path)
      params = {}
      elements = path.split('/')
      @params_base.each do |key, value|
        params[value] = elements[key]
      end
      params
    end

    alias_method(:[], :parse)
  end
end
