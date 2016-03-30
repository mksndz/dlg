module MultipleActionable
  extend ActiveSupport::Concern

  included do
  end

  def multiple_action
    klass = controller_name.classify.constantize
    if params[:commit].downcase.include? 'delete'
      # todo add can? call here and appropriate AdminAbility code
      message = delete_multiple(klass) ? 'Selected records deleted!' : 'Selected Records could not be deleted'
    elsif params[:commit].downcase.include? 'xml'
      message = xml_for_multiple(klass, params[:ids])
    end
    respond_to do |format|
      format.html { redirect_to url_for(controller: controller_name, action: 'search'), notice: '' }
    end
  end

  def delete_multiple(klass)
    klass.destroy(params[:ids])
  end

  def xml_for_multiple(klass, ids)
    # todo
  end

end