# frozen_string_literal: true

# controller for remediation actions
class RemediationActionsController < ApplicationController
  load_and_authorize_resource
  include ErrorHandling
  include Sorting
  include RemediationActionsHelper

  before_action :load_items, only: %i[review show]

  # show all ingests
  def index
    @remediation_actions = RemediationAction
                           .order(sort_column + ' ' + sort_direction)
                           .page(params[:page])
                           .per(params[:per_page])
  end

  def new
    @remediation_action = RemediationAction.new
  end

  def create
    @remediation_action = RemediationAction.new(
      remediation_action_params.merge(user: current_user)
    )
    RemediationService.prepare(@remediation_action)
    if @remediation_action.errors.any?
      render :new, notice:
        I18n.t('meta.defaults.messages.errors.not_created',
               entity: 'Remediation Action')
    elsif @remediation_action.items.empty?
      redirect_to new_remediation_action_path,
                  notice: 'No Items found matching your specification.'
    else
      redirect_to(review_remediation_action_path(@remediation_action),
                  notice: I18n.t('meta.defaults.messages.success.created',
                                 entity: 'Remediation Action'))
    end
  end

  def review; end

  def perform
    if RemediationService.run @remediation_action
      redirect_to(@remediation_action, notice: 'Remediation Performed!')
    else
      render :perform_form, alert: 'There was an issue - ask for help!'
    end
  end

  def show; end

  def destroy
    @remediation_action.destroy
    redirect_to remediation_actions_path, notice: I18n.t('meta.defaults.messages.success.destroyed', entity: 'Remediation Action')
  end

  private

  def remediation_action_params
    params.require(:remediation_action).permit(:field, :new_text, :old_text)
  end
  
  def load_items
    @items = Item.where(id: @remediation_action.items)
  end
end
