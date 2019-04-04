# support DPLA harvesting
class DplaController < ApplicationController
  include Blacklight::Catalog
  respond_to :json

  skip_before_action :authenticate_user!
  before_action :authenticate_token

  def index
    response = blacklight_query
    render json: {
      numFound: response['response']['numFound'],
      items: response['response']['docs'],
      nextCursorMark: response['nextCursorMark']
    }
  end

  def show
    response = Blacklight.default_index.find(
      params[:id], facet: false,
                   wt: 'json',
                   fq: 'display_b:1, dpla_b: 1, class_name_ss: Item',
                   fl: dpla_fields.join(', ')
    )
    render json: response['response']['docs'][0]
  end

  private

  def blacklight_query
    Blacklight.default_index.connection.get 'select', params: {
      rows: rows, facet: false, sort: 'id asc', wt: 'json',
      fq: 'display_b:1, dpla_b: 1, class_name_ss: Item',
      fl: dpla_fields.join(', '),
      cursorMark: cursor_mark
    }
  end

  def dpla_fields
    %w[id collection_titles_sms dcterms_provenance_display
       dcterms_title_display dcterms_creator_display dcterms_subject_display
       dcterms_description_display edm_is_shown_at_display
       edm_is_shown_by_display dc_date_display dcterms_spatial_display
       dc_format_display dc_right_display dcterms_type_display
       dcterms_language_display dlg_subject_personal_display
       dcterms_bibliographic_citation_display dcterms_identifier_display
       dc_relation_display dcterms_contributor_display
       dcterms_publisher_display dcterms_temporal_display
       dcterms_is_part_of_display dcterms_rights_holder_display
       dlg_local_right_display dcterms_medium_display dcterms_extent_display
       created_at_dts updated_at_dts]
  end

  def rows
    params[:rows] || '1000'
  end

  def cursor_mark
    params[:cursormark] ? URI.decode_www_form_component(params[:cursormark]).tr('%2B', ' ') : '*'
  end

  def authenticate_token
    if Devise.secure_compare request.headers['X-User-Token'], Rails.application.secrets.dpla_token
      true
    else
      head :unauthorized
    end
  end

end