# frozen_string_literal: true
class SearchHistoryController < ApplicationController
  include Blacklight::SearchHistory
  helper BlacklightMaps::RenderConstraintsOverride


  helper BlacklightAdvancedSearch::RenderConstraintsOverride
end
