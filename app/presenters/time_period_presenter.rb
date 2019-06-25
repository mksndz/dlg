class TimePeriodPresenter < Presenter
  def edit_button
    h.link_to h.t('meta.defaults.actions.edit'),
            h.edit_time_period_path(self),
            class: 'btn btn-default'
  end

  def name_field
    h.render 'shared/show_field',
             field_name: h.t('activerecord.attributes.time_period.name'),
             value: self.name
  end

  def id_link
    h.link_to id, h.time_period_path(self)
  end

  def name_link
    h.link_to name, h.time_period_path(self)
  end

  def entity_actions
    h.render partial: 'shared/entity_actions',
             locals: { base_path: h.time_period_path(self),
                       edit_path: h.edit_time_period_path(self),
                       entity: self,
                       show_bl: false }
  end

end