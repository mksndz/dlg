module BlacklightMapsHelper
  include Blacklight::BlacklightMapsHelperBehavior

  # create a link to a location name facet value
  def link_to_placename_field field_value, field, displayvalue = nil, link_options = {}
    if params[:f] && params[:f][field] && params[:f][field].include?(field_value)
      new_params = params
    else
      new_params = search_state.add_facet_params(field, field_value)
    end
    new_params[:view] = default_document_index_view_type
    link_to(displayvalue.presence || field_value,
            search_catalog_path(new_params.except(:id, :spatial_search_type, :coordinates)),
            link_options)
  end
end