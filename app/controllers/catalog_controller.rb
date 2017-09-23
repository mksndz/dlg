# -*- encoding : utf-8 -*-
class CatalogController < ApplicationController
  include BlacklightAdvancedSearch::Controller
  include Blacklight::Catalog
  include BlacklightMaps::ControllerOverride
  include MetadataHelper # for rights statement stuff

  ADVANCED_FACET_DEFAULT_LIMIT = 300

  authorize_resource class: false

  configure_blacklight do |config|

    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight reponse model
    # config.response_model = Blacklight::Solr::Response

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = { 
      qt: 'search',
      fq: '-class_name:Repository'
      # 'facet.limit' => 20
    }

    # facets are defined in query handler so this is not needed
    # makes debugging solr calls easier
    config.add_facet_fields_to_solr_request!
    
    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select' 

    # set maximum results per page (experimental)
    config.max_per_page = 20000

    # items to show per page, each number in the array represent another option to choose from.
    config.per_page = [20,50,100,1000]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    # config.default_document_solr_params = {
    #  :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}'
    # }

    # solr field configuration for search results/index views
    config.index.title_field = 'title'
    config.index.display_type_field = 'format'

    # solr field configuration for document/show views
    config.show.title_field = 'title'
    config.show.display_type_field = 'format'

    # show thumbnails on search results for most view types
    # config.index.thumbnail_field = :thumbnail_url
    config.index.thumbnail_method = :record_thumbnail

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.    
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or 
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.  
    #
    # :show may be set to false if you don't want the facet to be drawn in the 
    # facet bar
    config.add_facet_field 'public_b',                label: I18n.t('meta.search.facets.public'), helper_method: :boolean_facet_labels, limit: true
    config.add_facet_field 'dpla_b',                  label: I18n.t('meta.search.facets.dpla'), helper_method: :boolean_facet_labels, limit: true
    config.add_facet_field 'valid_item_b',            label: I18n.t('meta.search.facets.valid_item'), helper_method: :boolean_facet_labels, limit: true
    config.add_facet_field 'provenance_facet',        label: I18n.t('meta.search.facets.provenance'), limit: true
    config.add_facet_field 'publisher_facet',         label: I18n.t('meta.search.facets.publisher'), limit: true
    config.add_facet_field 'creator_facet',           label: I18n.t('meta.search.facets.creator'), limit: true
    config.add_facet_field 'contributor_facet',       label: I18n.t('meta.search.facets.contributor'), limit: true
    config.add_facet_field 'subject_facet',           label: I18n.t('meta.search.facets.subject'), limit: true
    config.add_facet_field 'subject_personal_facet',  label: I18n.t('meta.search.facets.subject_personal'), limit: true
    config.add_facet_field 'year_facet',              label: I18n.t('meta.search.facets.year'), limit: true
    config.add_facet_field 'temporal_facet',          label: I18n.t('meta.search.facets.temporal'), limit: true
    config.add_facet_field 'location_facet',          label: I18n.t('meta.search.facets.location'), limit: true
    config.add_facet_field 'counties_facet',          label: I18n.t('meta.search.facets.county'), limit: true
    config.add_facet_field 'format_facet',            label: I18n.t('meta.search.facets.format'), limit: true
    config.add_facet_field 'rights_facet',            label: I18n.t('meta.search.facets.rights'), limit: true, helper_method: :rights_icon_label
    # config.add_facet_field 'rights_holder_facet'    , label: I18n.t('meta.search.facets.rights_holder'), limit: true
    config.add_facet_field 'relation_facet',          label: I18n.t('meta.search.facets.relation'), limit: true
    config.add_facet_field 'type_facet',              label: I18n.t('meta.search.facets.type'), limit: true
    config.add_facet_field 'medium_facet',            label: I18n.t('meta.search.facets.medium'), limit: true
    config.add_facet_field 'language_facet',          label: I18n.t('meta.search.facets.language'), limit: true
    config.add_facet_field 'repository_name_sms',     label: I18n.t('meta.search.facets.repository'), limit: true
    config.add_facet_field 'collection_name_sms',     label: I18n.t('meta.search.facets.collection'), limit: true
    config.add_facet_field 'portal_names_sms',        label: I18n.t('meta.search.facets.portals'), limit: true
    config.add_facet_field 'class_name',              label: I18n.t('meta.search.facets.class'), limit: true

    # collection only facets
    config.add_facet_field 'collection_provenance_facet', label: I18n.t('meta.search.facets.collection_only.provenance'), limit: true
    config.add_facet_field 'collection_type_facet',       label: I18n.t('meta.search.facets.collection_only.type'), limit: true
    config.add_facet_field 'collection_spatial_facet',    label: I18n.t('meta.search.facets.collection_only.spatial'), limit: true


    #
    # config.add_facet_field 'example_pivot_field', :label => 'Pivot Field', :pivot => ['format', 'language_facet']
    #
    # config.add_facet_field 'updated_at_dts', :label => 'Updated', :query => {
    #   :day => { :label => 'within 1 day', :fq => "updated_at_dts:[#{Time.zone.now.day - 1 } TO *]" },
    #   :week => { :label => 'within 1 week', :fq => "updated_at_dts:[#{Time.zone.now.day - 7 } TO *]" },
    #   :month => { :label => 'within 1 month', :fq => "updated_at_dts:[#{Time.zone.now.month - 1 } TO *]" },
    #   :year => { :label => 'within 1 year', :fq => "updated_at_dts:[#{Time.zone.now.year - 1 } TO *]" }
    # }
    # config.add_facet_field 'created_at_dts', :label => 'Created', :query => {
    #   :day => { :label => 'within 1 day', :fq => "created_at_dts:[#{Time.zone.now.day - 1.day } TO *]" },
    #   :week => { :label => 'within 1 week', :fq => "created_at_dts:[#{Time.zone.now.day - 7.days } TO *]" },
    #   :month => { :label => 'within 1 month', :fq => "created_at_dts:[#{Time.zone.now.month - 1.month } TO *]" },
    #   :year => { :label => 'within 1 year', :fq => "created_at_dts:[#{Time.zone.now.year - 1.year } TO *]" }
    # }

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'record_id_ss',                label: I18n.t('meta.search.labels.record_id')
    config.add_index_field 'dcterms_title_display',       label: I18n.t('meta.search.labels.dcterms_title')
    config.add_index_field 'dcterms_description_display', label: I18n.t('meta.search.labels.dcterms_description'), helper_method: 'truncate_index'
    config.add_index_field 'collection_name_sms',         label: I18n.t('meta.search.labels.collection'), link_to_search: true
    config.add_index_field 'repository_name_sms',         label: I18n.t('meta.search.labels.repository'), link_to_search: true
    config.add_index_field 'dcterms_identifier_display',  label: I18n.t('meta.search.labels.dcterms_identifier')
    config.add_index_field 'edm_is_shown_at_display',     label: I18n.t('meta.search.labels.edm_is_shown_at'), helper_method: 'linkify'
    config.add_index_field 'edm_is_shown_by_display',     label: I18n.t('meta.search.labels.edm_is_shown_by'), helper_method: 'linkify'
    config.add_index_field 'dcterms_creator_display',     label: I18n.t('meta.search.labels.dcterms_creator'), link_to_search: :creator_facet
    config.add_index_field 'dc_format_display',           label: I18n.t('meta.search.labels.dc_format'), link_to_search: :format_facet
    config.add_index_field 'dcterms_spatial_display',     label: I18n.t('meta.search.labels.dcterms_spatial'), link_to_search: :location_facet
    config.add_index_field 'dpla_ss',                     label: I18n.t('meta.search.labels.dpla')
    config.add_index_field 'public_ss',                   label: I18n.t('meta.search.labels.public')
    config.add_index_field 'display_ss',                  label: I18n.t('meta.search.labels.display')
    config.add_index_field 'valid_item_ss',               label: I18n.t('meta.search.labels.valid_item')

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'slug_ss',                                label: I18n.t('meta.search.labels.item_id')
    config.add_show_field 'record_id_ss',                           label: I18n.t('meta.search.labels.record_id')
    config.add_show_field 'dcterms_title_display',                  label: I18n.t('meta.search.labels.dcterms_title')
    config.add_show_field 'collection_name_sms',                    label: I18n.t('meta.search.labels.collection'), link_to_search: true
    config.add_show_field 'repository_name_sms',                    label: I18n.t('meta.search.labels.repository'), link_to_search: true
    config.add_show_field 'display_title_display',                  label: I18n.t('meta.search.labels.display_title')
    config.add_show_field 'short_description_display',              label: I18n.t('meta.search.labels.short_description')
    config.add_show_field 'partner_homepage_url_display',           label: I18n.t('meta.search.labels.partner_homepage_url')
    config.add_show_field 'homepage_text_display',                  label: I18n.t('meta.search.labels.homepage_text')
    config.add_show_field 'dcterms_is_part_of_display',             label: I18n.t('meta.search.labels.dcterms_is_part_of')
    config.add_show_field 'dcterms_description_display',            label: I18n.t('meta.search.labels.dcterms_description')
    config.add_show_field 'dc_format_display',                      label: I18n.t('meta.search.labels.dc_format')
    config.add_show_field 'dcterms_identifier_display',             label: I18n.t('meta.search.labels.dcterms_identifier')
    config.add_show_field 'dc_right_display',                       label: I18n.t('meta.search.labels.dc_right'), helper_method: 'rights_icon_tag'
    config.add_show_field 'dc_date_display',                        label: I18n.t('meta.search.labels.dc_date')
    config.add_show_field 'dc_relation_display',                    label: I18n.t('meta.search.labels.dc_relation')
    config.add_show_field 'dcterms_publisher_display',              label: I18n.t('meta.search.labels.dcterms_publisher')
    config.add_show_field 'dcterms_contributor_display',            label: I18n.t('meta.search.labels.dcterms_contributor')
    config.add_show_field 'dcterms_temporal_display',               label: I18n.t('meta.search.labels.dcterms_temporal')
    config.add_show_field 'dcterms_spatial_display',                label: I18n.t('meta.search.labels.dcterms_spatial'), link_to_search: :location_facet
    config.add_show_field 'dcterms_provenance_display',             label: I18n.t('meta.search.labels.dcterms_provenance')
    config.add_show_field 'dcterms_subject_display',                label: I18n.t('meta.search.labels.dcterms_subject'), link_to_search: :subject_facet
    config.add_show_field 'dcterms_type_display',                   label: I18n.t('meta.search.labels.dcterms_type')
    config.add_show_field 'dcterms_creator_display',                label: I18n.t('meta.search.labels.dcterms_creator'), link_to_search: :creator_facet
    config.add_show_field 'dcterms_language_display',               label: I18n.t('meta.search.labels.dcterms_language')
    config.add_show_field 'edm_is_shown_at_display',                label: I18n.t('meta.search.labels.edm_is_shown_at'), helper_method: 'linkify'
    config.add_show_field 'edm_is_shown_by_display',                label: I18n.t('meta.search.labels.edm_is_shown_by'), helper_method: 'linkify'
    config.add_show_field 'dcterms_rights_holder_display',          label: I18n.t('meta.search.labels.dcterms_rights_holder')
    config.add_show_field 'dcterms_bibliographic_citation_display', label: I18n.t('meta.search.labels.dcterms_bibliographic_citation')
    config.add_show_field 'dcterms_extent_display',                 label: I18n.t('meta.search.labels.dcterms_extent')
    config.add_show_field 'dcterms_medium_display',                 label: I18n.t('meta.search.labels.dcterms_medium')
    config.add_show_field 'dlg_subject_personal_display',           label: I18n.t('meta.search.labels.dlg_subject_personal')
    config.add_show_field 'created_at_dts',                         label: I18n.t('meta.search.labels.created_at')
    config.add_show_field 'updated_at_dts',                         label: I18n.t('meta.search.labels.updated_at')


    # ADVANCED SEARCH CONFIG

    config.advanced_search = Blacklight::OpenStructWithHashAccess.new
    config.advanced_search[:qt]                   ||= 'advanced'
    config.advanced_search[:url_key]              ||= 'advanced'
    config.advanced_search[:query_parser]         ||= 'dismax'
    config.advanced_search[:form_facet_partial]   ||= 'advanced_search_facets_as_select'
    config.advanced_search[:form_solr_parameters] ||= {
      'f.provenance_facet.facet.limit' => ADVANCED_FACET_DEFAULT_LIMIT,
      'f.creator_facet.facet.limit' => ADVANCED_FACET_DEFAULT_LIMIT,
      'f.contributor_facet.facet.limit' => ADVANCED_FACET_DEFAULT_LIMIT,
      'f.subject_facet.facet.limit' => ADVANCED_FACET_DEFAULT_LIMIT,
      'f.year_facet.facet.limit' => ADVANCED_FACET_DEFAULT_LIMIT,
      'f.temporal_facet.facet.limit' => ADVANCED_FACET_DEFAULT_LIMIT,
      'f.location_facet.facet.limit' => ADVANCED_FACET_DEFAULT_LIMIT,
      'f.rights_facet.facet.limit' => ADVANCED_FACET_DEFAULT_LIMIT,
      'f.publisher_facet.facet.limit' => ADVANCED_FACET_DEFAULT_LIMIT,
      # 'f.rights_holder_facet.facet.limit' => ADVANCED_FACET_DEFAULT_LIMIT,
      'f.relation_facet.facet.limit' => ADVANCED_FACET_DEFAULT_LIMIT,
      'f.type_facet.facet.limit' => ADVANCED_FACET_DEFAULT_LIMIT,
      'f.medium_facet.facet.limit' => ADVANCED_FACET_DEFAULT_LIMIT,
      'f.language_facet.facet.limit' => ADVANCED_FACET_DEFAULT_LIMIT,
      'f.repository_name_sms.facet.limit' => -1,
      'f.collection_name_sms.facet.limit' => -1,
      'f.portals_sms.facet.limit' => ADVANCED_FACET_DEFAULT_LIMIT
    }

    config.add_search_field('all_fields') do |field|
      # field.include_in_advanced_search = false # no results returned in advanced search
    end

    # slug
    config.add_search_field('slug') do |field|
      field.label = 'ID (slug)'
      field.solr_local_parameters = {
          qf: 'slug_ng',
          pf: 'slug_ng'
      }
    end

    # record id
    config.add_search_field('record_id') do |field|
      field.label = 'Record ID'
      field.solr_local_parameters = {
          qf: 'record_id_ng',
          pf: 'record_id_ng'
      }
    end

    # title
    config.add_search_field('title') do |field|
      field.label = 'Title'
      field.solr_local_parameters = {
          qf: 'title_unstem_search^100 dcterms_title_text^50',
          pf: 'title_unstem_search^100 dcterms_title_text^50'
      }
    end

    # creator
    config.add_search_field('creator') do |field|
      field.label = 'Creator'
      field.solr_local_parameters = {
          qf: 'creator_unstem_search^100 dcterms_creator_text^50',
          pf: 'creator_unstem_search^100 dcterms_creator_text^50'
      }
    end

    # contributor
    config.add_search_field('contributor') do |field|
      field.label = 'Contributor'
      field.solr_local_parameters = {
          qf: 'contributor_unstem_search^100 dcterms_contributor_text^50',
          pf: 'contributor_unstem_search^100 dcterms_contributor_text^50'
      }
    end

    # subject
    config.add_search_field('subject') do |field|
      field.label = 'Subject'
      field.solr_local_parameters = {
          qf: 'subject_unstem_search^100 dcterms_subject_text^50',
          pf: 'subject_unstem_search^100 dcterms_subject_text^50'
      }
    end

    # description
    config.add_search_field('description') do |field|
      field.label = 'Description'
      field.solr_local_parameters = {
          qf: 'description_unstem_search^100 dcterms_description_text^50',
          pf: 'description_unstem_search^100 dcterms_description_text^50'
      }
    end

    # publisher
    config.add_search_field('publisher') do |field|
      field.label = 'Publisher'
      field.solr_local_parameters = {
          qf: 'publisher_unstem_search^100 dcterms_publisher_text^50',
          pf: 'publisher_unstem_search^100 dcterms_publisher_text^50'
      }
    end

    # date
    config.add_search_field('date') do |field|
      field.label = 'Date'
      field.solr_local_parameters = {
          qf: 'date_unstem_search^100 dc_date_text^50',
          pf: 'date_unstem_search^100 dc_date_text^50'
      }
    end

    # temporal / dcterms_temporal
    config.add_search_field('temporal') do |field|
      field.label = 'Temporal'
      field.solr_local_parameters = {
          qf: 'temporal_unstem_search^100 dcterms_temporal_text^50',
          pf: 'temporal_unstem_search^100 dcterms_temporal_text^50'
      }
    end

    # place / dcterms_spatial
    config.add_search_field('spatial') do |field|
      field.label = 'Spatial'
      field.solr_local_parameters = {
          qf: 'spatial_unstem_search^100 dcterms_spatial_text^50',
          pf: 'spatial_unstem_search^100 dcterms_spatial_text^50'
      }
    end

    # is part of
    config.add_search_field('is_part_of') do |field|
      field.label = 'Is Part Of'
      field.solr_local_parameters = {
          qf: 'is_part_of_unstem_search^100 dcterms_is_part_of_text^50',
          pf: 'is_part_of_unstem_search^100 dcterms_is_part_of_text^50'
      }
    end

    # is shown at
    config.add_search_field('is_shown_at') do |field|
      field.label = 'Is Shown At (URL)'
      field.solr_local_parameters = {
          qf: 'edm_is_shown_at_url^1000 edm_is_shown_at_text^100',
          pf: 'edm_is_shown_at_url^1000 edm_is_shown_at_text^100'
      }
    end

    # is shown by
    config.add_search_field('is_shown_by') do |field|
      field.label = 'Is Shown By (URL)'
      field.solr_local_parameters = {
          qf: 'edm_is_shown_by_url^1000 edm_is_shown_by_text^100',
          pf: 'edm_is_shown_by_url^1000 edm_is_shown_by_text^100'
      }
    end

    # identifier
    config.add_search_field('identifier') do |field|
      field.label = 'Identifier'
      field.solr_local_parameters = {
          qf: 'dcterms_identifier_url^1000 identifier_unstem_search^100 dcterms_identifier_text^50',
          pf: 'dcterms_identifier_url^1000 identifier_unstem_search^100 dcterms_identifier_text^50'
      }
    end

    # identifier
    config.add_search_field('rights_holder') do |field|
      field.label = 'Rights Holder'
      field.solr_local_parameters = {
          qf: 'dcterms_rights_holder_text^500 dcterms_rights_holder_unstem_search^50',
          pf: 'dcterms_rights_holder_text^500 dcterms_rights_holder_unstem_search^50'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, title_sort asc', label: 'Relevance'
    config.add_sort_field 'year asc', label: 'Year'
    config.add_sort_field 'title_sort asc', label: 'DC Title'
    config.add_sort_field 'collection_sort asc', label: 'Collection'
    config.add_sort_field 'creator_sort asc', label: 'DC Creator'
    config.add_sort_field 'created_at_dts desc', label: 'Latest Created'
    config.add_sort_field 'updated_at_dts desc', label: 'Latest Updated'

    # If there are more than this many search results, no spelling ("did you 
    # mean") suggestion is offered.
    config.spell_max = 5

    # remove citation and SMS tools
    config.show.document_actions.delete(:citation)
    config.show.document_actions.delete(:sms)

    # AUTOCOMPLETE CONFIG
    config.autocomplete_enabled = false
    config.autocomplete_path = 'suggest'

    # MAPS CONFIG
    config.add_facet_field 'geojson', label: 'Coordinates', limit: -2, show: false
    config.view.maps.geojson_field      = 'geojson'
    config.view.maps.placename_field    = 'placename'
    config.view.maps.coordinates_field  = 'coordinates'
    config.view.maps.search_mode        = 'placename'
    config.view.maps.facet_mode         = 'geojson'
    config.view.maps.initialview        = '[[27.741885,-96.987305],[37.874853,-71.279297]]'
    config.view.maps.maxzoom            = 12
    config.view.maps.show_initial_zoom  = 9
    config.show.partials                << :show_maplet

    # GALLERY CONFIG
    config.view.gallery.partials    = [:index_header, :index]
    config.view.masonry.partials    = [:index]
    config.view.slideshow.partials  = [:index]
    # config.show.tile_source_field   = :thumbnail_url
    # config.show.partials.insert(1, :openseadragon) # wont work with thumbs on different server...i think

    # remove standard blacklight navbar links (they are in user tools menu now)
    config.navbar.partials.delete(:bookmark)
    config.navbar.partials.delete(:saved_searches)
    config.navbar.partials.delete(:search_history)
  end

  # add Admin and Search menu to navbar
  add_nav_action :search
  add_nav_action :admin

  # add "Export as XML" button on search results
  add_results_collection_tool :action_widget

  def facets
    @facets = displayed_facets
  end

  def all_facet_values
    facet = blacklight_config.facet_fields[params[:facet_field]]
    blacklight_config.default_facet_limit = -1 # return all values
    response, _ = search_results({})
    display_facet = response.aggregations[facet.key]
    @field = display_facet.name
    @values = display_facet.items.map { |v| { value: v.value, hits: v.hits } }
    respond_to do |format|
      format.csv { render :all_facets }
    end
  end

  private

  def displayed_facets
    facets = []
    blacklight_config.facet_fields.each do |f|
      facet = f[1]
      facets << facet if facet[:show] == true
    end
    facets
  end

end
