class SubjectDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def id_link
    h.link_to id, h.subject_path(self)
  end

  def name_link
    h.link_to name, h.subject_path(self)
  end

  def edit_link
    h.link_to h.t('meta.defaults.actions.edit'),
            h.edit_subject_path(self),
            class: 'btn btn-default'
  end

  def entity_actions
    h.render partial: 'shared/entity_actions',
             locals: { base_path: h.subject_path(subject),
                       edit_path: h.edit_subject_path(subject),
                       entity: subject, show_bl: false }
  end

end
