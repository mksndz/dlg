class Presenter < SimpleDelegator

  def initialize(model, view_context)
    super model
    @view_context = view_context
  end

  # Used to call helper methods from the Presenter
  def h
    @view_context
  end
end