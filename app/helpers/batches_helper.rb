module BatchesHelper

  def commit_status_for(batch)
    if batch.committed?
      batch.committed_at
    elsif batch.pending?
      I18n.t('meta.batch.labels.commit_pending', time: time_ago_in_words(batch.queued_for_commit_at))
    else
      I18n.t('meta.batch.labels.not_yet_committed')
    end
  end

end