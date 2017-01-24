module Sorting
  extend ActiveSupport::Concern

  included do
    helper_method :sort_column, :sort_direction
  end

  # this is injection safe because if ensures the params value is in the column_names array from the entity
  def sort_column(table = nil)
    begin
      table = table ? table : controller_name.downcase
      check_columns_for_field(controller_name, params[:sort]) ? params[:sort] : "#{table}.id"
    rescue NameError
      table = table ? table : controller_path.downcase
      check_columns_for_field(controller_path, params[:sort]) ? params[:sort] : "#{table}.id"
    end
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  private

  def current_class(entity)
    entity.classify.constantize
  end

  def check_columns_for_field(entity, field)
    current_class(entity).column_names.include?(field)
  end

end