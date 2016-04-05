module Meta
  class MetaController < ApplicationController
    layout 'admin'

    def current_ability
      @current_ability ||= AdminAbility.new(current_meta_admin)
    end

  end
end

