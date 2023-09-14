module LegoTec
  class WebApp
    module Views
      class Layout < View
        def initialize(body)
          @body = body
        end
        attr_reader :body

        def body
          @body.render
        end

        def is_bus_lines_page
          @body.is_bus_lines_page
        end

        def is_mobility_matrix_page
          @body.is_mobility_matrix_page
        end
      end
    end
  end
end
