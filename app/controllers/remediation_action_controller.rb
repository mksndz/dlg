# frozen_string_literal: true

# controller for remediation actions
class RemediationActionController < ApplicationController
  load_and_authorize_resource
  include ErrorHandling
  include Sorting

  rescue_from InvalidRemediationError do |e|
    redirect_to new_remediation_action_path, alert: e.message
  end

  # show all ingests
  def index
    @remediation_actions = RemediationAction
                             .order(sort_column + ' ' + sort_direction)
                             .page(params[:page])
                             .per(params[:per_page])
  end

  # show form to create a new remediation action
  def new
    @remediation_action = RemediationAction.new
  end

  def create
    #@remediation_action.run
    #  Resque.enqueue(PageProcessor, @remediation_action.id)
    #  redirect_to(
    #    @remediation_action,
    #    notice: I18n.t('meta.remediation_actions.messages.success.queued')
    #  )
    #else
    #  render :new, alert:
    #    I18n.t('meta.defaults.messages.errors.not_created',
    #           entity: 'Remediation Action')
    #end
  end

  def show; end

  def destroy
    @remediation_action.destroy
    redirect_to remediation_actions_path, notice: I18n.t('meta.defaults.messages.success.destroyed', entity: 'Page Ingest')
  end

  private

  def remediation_action_params
    params.require(:remediation_action).permit(:field, :new_text, :old_text)
  end
end
