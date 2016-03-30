module MultipleActionable
  extend ActiveSupport::Concern

  def multiple_action
    klass = controller_name.classify.constantize
    if params[:commit].downcase.include? 'delete'
      if can?(:multiple_delete, Item)
        delete_multiple(klass)
      end
    elsif params[:commit].downcase.include? 'xml'
      if can?(:multiple_delete, Item)
        xml_for_multiple(klass, params[:ids])
      end
    else
      respond_to do |format|
        format.html { redirect_to url_for(controller: controller_name, action: 'search'), alert: 'Bad action specified!' }
      end
    end

  end

  def delete_multiple(klass)
    klass.destroy(params[:ids])
    respond_to do |format|
      format.html { redirect_to url_for(controller: controller_name, action: 'search'), notice: 'Selected records deleted!' }
    end
  end

  def xml_for_multiple(klass, ids)
    # todo refactor this
    #   have an model method that outputs grouped XML for the model, receiving array of IDs
    #   output the XML properly, perhaps as a file download or a xml well in a nice html page?
    xml = "<#{klass.to_s.downcase.pluralize}>\n"
    ids.each do |id|
      xml += "#{klass.find(id).to_xml(skip_instruct: true)}"
    end
    xml += "</#{klass.to_s.downcase.pluralize}>"
    respond_to do |format|
      format.html { render plain: xml }
    end
  end

end