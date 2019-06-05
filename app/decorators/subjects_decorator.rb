class SubjectsDecorator < Draper::CollectionDecorator

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def id_header
    h.sortable 'subjects.id', h.t('meta.defaults.labels.columns.id')
  end

  def name_header
    h.sortable 'subjects.name', h.t('meta.defaults.labels.columns.name')
  end

end
