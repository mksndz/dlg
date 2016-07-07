# frozen_string_literal: true
class SavedSearchesController < ApplicationController
  include Blacklight::SavedSearches
  helper BlacklightMaps::RenderConstraintsOverride


  helper BlacklightAdvancedSearch::RenderConstraintsOverride
end
