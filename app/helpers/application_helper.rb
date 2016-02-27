module ApplicationHelper

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == 'asc' ? 'desc' : 'asc'
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

  # set menu items as 'active'
  def admin_active_class(key)
    request.original_url.include?('/' + key) ? 'active' : ''
  end

  # Generate JS-friendly set of inputs for the entity and attribute
  def text_field_multi(object, term)

    @object = object
    @term = term

    label = t @term, scope: [:activerecord, :attributes, class_name]
    help = t @term, scope: [:activerecord, :help, class_name]

    html = "<div class='form-group'><label class='control-label' for='#{field_name}'>#{label}</label>"
    html += "<span id='helpBlock' class='help-block'>#{help}</span>"
    html += object[term].is_a?(Array) ? object[term].map { |t| input t }.join + input : input
    html += '</div>'.html_safe
    html.html_safe

  end

  private

  def input(value = nil)
    "<input class='form-control' type='text' value='#{h value}' name='#{input_name}'>"
  end

  def field_name
    "#{class_name}_#{@term}"
  end

  def input_name
    "#{class_name}[#{@term}][]"
  end

  def class_name
    @object.class.name.demodulize.underscore
  end

end
