# -*- encoding : utf-8 -*-
class CatalogController < ApplicationController
  include BlacklightAdvancedSearch::Controller
  include Blacklight::Catalog

  authorize_resource class: false

  configure_blacklight do |config|
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'dismax'
    config.advanced_search[:form_solr_parameters] ||= {}

    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = { 
      qt: 'search',
      # fq: '-class_name:"BatchItem"-class_name:"Batch"', # dont return BatchItems or Batches
      rows: 20
    }

    config.add_facet_fields_to_solr_request!
    
    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select' 
    
    # items to show per page, each number in the array represent another option to choose from.
    config.per_page = [20,50,100,200]

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
    config.index.title_field = 'dcterms_title_display'
    config.index.display_type_field = 'format_ss'

    # solr field configuration for document/show views
    config.show.title_field = 'dcterms_title_display'
    config.show.display_type_field = 'format_ss'

    # show thumbnails on search results
    config.view.list.thumbnail_field = :thumbnail_url_ss

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
    config.add_facet_field 'format_ss',          label: 'Format*',     limit: true
    config.add_facet_field 'location_facet',     label: 'Location',    limit: true
    config.add_facet_field 'subject_facet',      label: 'Subject',     limit: true
    config.add_facet_field 'type_facet',         label: 'Type',        limit: true
    config.add_facet_field 'creator_facet',      label: 'Creator',     limit: true
    config.add_facet_field 'temporal_facet',     label: 'Temporal',    limit: true
    config.add_facet_field 'public_b',           label: 'Public?',     limit: true, helper_method: :boolean_facet_labels
    config.add_facet_field 'dpla_b',             label: 'DPLA?',       limit: true, helper_method: :boolean_facet_labels
    config.add_facet_field 'collection_name_ss', label: 'Collection',  limit: true
    config.add_facet_field 'repository_name_ss', label: 'Repository',  limit: true

    #
    # config.add_facet_field 'example_pivot_field', :label => 'Pivot Field', :pivot => ['format', 'language_facet']
    #
    # config.add_facet_field 'example_query_facet_field', :label => 'Publish Date', :query => {
    #   :years_5 => { :label => 'within 5 Years', :fq => "pub_date:[#{Time.zone.now.year - 5 } TO *]" },
    #   :years_10 => { :label => 'within 10 Years', :fq => "pub_date:[#{Time.zone.now.year - 10 } TO *]" },
    #   :years_25 => { :label => 'within 25 Years', :fq => "pub_date:[#{Time.zone.now.year - 25 } TO *]" }
    # }


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    # config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display

    config.add_index_field 'dcterms_title_display', :label => 'Title'
    config.add_index_field 'dcterms_description_display', :label => 'Description'
    config.add_index_field 'collection_name_ss', :label => 'Collection', link_to_search: true
    config.add_index_field 'repository_name_ss', :label => 'Repository', link_to_search: true
    config.add_index_field 'dc_identifier_display', :label => 'Identifier', helper_method: 'linkify'
    config.add_index_field 'dc_creator_display', :label => 'Author'
    config.add_index_field 'dc_type_display', :label => 'Format'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'dcterms_title_display', :label => 'Title'
    config.add_show_field 'collection_name_ss', :label => 'Collection'
    config.add_show_field 'dcterms_is_part_of_display', :label => 'Is Part Of'
    config.add_show_field 'dcterms_description_display', :label => 'Description'
    config.add_show_field 'dc_format_display', :label => 'File Format'
    config.add_show_field 'dc_identifier_display', :label => 'Identifier', helper_method: 'linkify'
    config.add_show_field 'dc_right_display', :label => 'Rights'
    config.add_show_field 'dc_date_display', :label => 'Date'
    config.add_show_field 'dc_relation_display', :label => 'Related Materials'
    config.add_show_field 'dcterms_publisher_display', :label => 'Publisher'
    config.add_show_field 'dcterms_contributor_display', :label => 'Contributor'
    config.add_show_field 'dcterms_temporal_display', :label => 'Time'
    config.add_show_field 'dcterms_spatial_display', :label => 'Place'
    config.add_show_field 'dcterms_provenance_display', :label => 'Location of Original'
    config.add_show_field 'dcterms_subject_display', :label => 'Subject'
    config.add_show_field 'dcterms_type_display', :label => 'Genre'
    config.add_show_field 'dcterms_creator_display', :label => 'Creator'
    config.add_show_field 'dcterms_language_display', :label => 'Language'
    config.add_show_field 'dcterms_is_shown_at_display', :label => 'URL', helper_method: 'linkify'
    config.add_show_field 'dcterms_rights_holder_display', :label => 'Rights Holder'
    config.add_show_field 'dcterms_access_right_display', :label => 'Access'
    config.add_show_field 'dcterms_extent_display', :label => 'Extent'
    config.add_show_field 'dcterms_medium_display', :label => 'Medium'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same:qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different. 

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field 'all_fields', :label => 'All Fields'

    config.add_search_field('rights') do |field|
      field.label = 'Rights Fields'
      field.if = false
      field.solr_local_parameters = {
          qf: 'dc_right_text^50000 dcterms_access_right_text^40000 dcterms_rights_holder_text^30000',
          pf: 'dc_right_text^50000 dcterms_access_right_text^40000 dcterms_rights_holder_text^30000'
      }
    end

    config.add_search_field('description') do |field|
      field.label = 'Description'
      field.solr_local_parameters = {
          qf: 'dcterms_description_text^50000',
          pf: 'dcterms_description_text^50000'
      }
    end

    config.add_search_field('title') do |field|
      field.label = 'Title'
      field.if = false
      field.solr_local_parameters = {
          qf: 'dcterms_title_text^50000',
          pf: 'dcterms_title_text^50000'
      }
    end

    config.add_search_field('publisher') do |field|
      field.label = 'Publisher'
      field.if = false
      field.solr_local_parameters = {
          qf: 'dcterms_publisher_text^50000',
          pf: 'dcterms_publisher_text^50000'
      }
    end

    config.add_search_field('contributor') do |field|
      field.label = 'Contributor'
      field.if = false
      field.solr_local_parameters = {
          qf: 'dcterms_contributor_text^50000',
          pf: 'dcterms_contributor_text^50000'
      }
    end

    config.add_search_field('place') do |field|
      field.label = 'Place'
      field.solr_local_parameters = {
          qf: 'dcterms_spatial_text^50000',
          pf: 'dcterms_spatial_text^50000'
      }
    end

    config.add_search_field('subject') do |field|
      field.label = 'Subject'
      field.solr_local_parameters = {
          qf: 'dcterms_subject_text^50000',
          pf: 'dcterms_subject_text^50000'
      }
    end

    # dummy demo fields
    # config.add_search_field('Description/Abstract') do |field|
    #   field.solr_local_parameters = {
    #     fq: ''
    #   }
    # end
    # config.add_search_field('Rights') do |field|
    #   field.solr_local_parameters = {
    #     fq: ''
    #   }
    # end
    # config.add_search_field('Any field or Combo of Fields') do |field|
    #   field.solr_local_parameters = {
    #     fq: ''
    #   }
    # end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, sort_title_s asc', :label => 'relevance'
    # config.add_sort_field 'pub_date_sort desc, title_sort asc', :label => 'year'
    config.add_sort_field 'sort_title_s asc', :label => 'title'

    # If there are more than this many search results, no spelling ("did you 
    # mean") suggestion is offered.
    config.spell_max = 5

    # enable XML output for search results
    config.index.respond_to.xml = Proc.new {
      render xml: solr_to_ar.to_xml
    }

    # remove citation and SMS tools
    config.show.document_actions.delete(:citation)
    config.show.document_actions.delete(:sms)

  end

  # add Admin menu to navbar
  add_nav_action :admin

  # add Edit button on search results
  add_results_document_tool :meta

  # add "Export as XML" button on search results
  # add_results_collection_tool :export_as_xml # todo not working

  private

  def solr_to_ar
    @response['response']['docs'].map do |d|
      klass, id = d['sunspot_id_ss'].split(' ')
      klass.constantize.find(id)
    end
  end

end
