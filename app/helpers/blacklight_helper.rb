module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def facet_more_link_threshold
    10
  end

end