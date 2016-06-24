module Sorting
  extend ActiveSupport::Concern

  included do
    helper_method :sort_column, :sort_direction
  end

  # this is injection safe because if ensures the params value is in the column_names array from the entity
  def sort_column
    begin
      check_columns_for_field(controller_name, params[:sort]) ? params[:sort] : 'id'
    rescue NameError
      check_columns_for_field(controller_path, params[:sort]) ? params[:sort] : 'id'
    end
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  private

  def check_columns_for_field(entity, field)
    entity.classify.constantize.column_names.include?(field)
  end

end