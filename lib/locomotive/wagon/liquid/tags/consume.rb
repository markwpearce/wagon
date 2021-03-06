module Locomotive
  module Wagon
    module Liquid
        module Tags

        # Consume web services as easy as pie directly in liquid !
        #
        # Usage:
        #
        # {% consume blog from 'http://nocoffee.tumblr.com/api/read.json?num=3' username: 'john', password: 'easy', format: 'json', expires_in: 3000 %}
        #   {% for post in blog.posts %}
        #     {{ post.title }}
        #   {% endfor %}
        # {% endconsume %}
        #
        class Consume < ::Liquid::Block

          Syntax = /(#{::Liquid::VariableSignature}+)\s*from\s*(#{::Liquid::QuotedString}+)/

          def initialize(tag_name, markup, tokens, context)
            if markup =~ Syntax
              @target = $1
              @url = $2.gsub(/['"]/, '')
              @options = {}
              markup.scan(::Liquid::TagAttributes) do |key, value|
                @options[key] = value if key != 'http'
              end
              @options.delete('expires_in')
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'consume' - Valid syntax: consume <var> from \"<url>\" [username: value, password: value]")
            end

            super
          end

          def render(context)
            context.stack do
              _response = nil

              begin
                _response = Locomotive::Wagon::Httparty::Webservice.consume(@url, @options.symbolize_keys)
              rescue Exception => e
                _response = { 'error' => e.message.to_s }.to_liquid
              end

              context.scopes.last[@target.to_s] = _response

              render_all(@nodelist, context)
            end
          end

        end

        ::Liquid::Template.register_tag('consume', Consume)
      end
    end
  end
end