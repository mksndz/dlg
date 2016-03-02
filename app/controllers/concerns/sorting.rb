module Sorting
  extend ActiveSupport::Concern

  included do
    helper_method :sort_column, :sort_direction
  end

  def sort_column
    controller_name.classify.constantize.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

end