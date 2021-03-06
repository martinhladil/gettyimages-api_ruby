require_relative 'RequestBase'

class SearchImages < RequestBase
  CONNECT_ROUTE = '/v3/search/images'.freeze # mashery endpoint
  @@search_route = CONNECT_ROUTE
  QUERY_PARAMS_NAMES = [
    'phrase',
    'age_of_people',
    'compositions',
    'editorial_segments',
    'ethnicity',
    'graphical_styles',
    'license_models',
    'orientations',
    'exclude_nudity',
    'embed_content_only',
    'sort_order',
    'page',
    'page_size'
  ].freeze

  QUERY_PARAMS_NAMES.each do |key|
    define_method :"with_#{key}" do |value = true|
      if value.is_a?(Array)
        build_query_params(key, value.join(','))
      else
        build_query_params(key, value)
      end
      self
    end
  end

  # {https://connect.gettyimages.com/swagger/ui/index.html#!/Search/Search_GetCreativeImagesByPhrase Creative Swagger}
  # with_graphical_styles
  # with_license_models
  def creative
    @@search_route = "#{CONNECT_ROUTE}/creative"
    self
  end

  def editorial
    @@search_route = "#{CONNECT_ROUTE}/editorial"
    self
  end

  def execute
    @http_helper.get(@@search_route, @query_params)
  end
end
