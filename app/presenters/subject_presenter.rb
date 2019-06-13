class SubjectPresenter < Presenter

  def id_link
    h.link_to id, h.subject_path(self)
  end

  def name_link
    h.link_to name, h.subject_path(self)
  end

  def entity_actions
    h.render partial: 'shared/entity_actions',
           locals: { base_path: h.subject_path(self),
                     edit_path: h.edit_subject_path(self),
                     entity: self, show_bl: false }
  end


  def edit_button
    h.link_to h.t('meta.defaults.actions.edit'),
              h.edit_subject_path(self),
              class: 'btn btn-default'
  end

  def name_field
    h.render 'shared/show_field',
             field_name: h.t('activerecord.attributes.subject.name'),
             value: name
  end



end