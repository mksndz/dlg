crumb :root do
  link 'Home', root_path
end

# SEARCH

crumb :basic_search do
  link 'Basic Search'
end

crumb :advanced_search do
  link 'Advanced Search'
end

crumb :map_search do
  link 'Map Search'
end

crumb :facets_browse do
  link 'Facet Browse'
end

crumb :facet_browse do |facet|
  link facet
  parent :facets_browse
end

# PROFILE

crumb :profile do
  link 'Profile'
end

crumb :change_password do
  link 'Change Password'
end

# REPOSITORY

crumb :repositories do
  link 'Repositories', repositories_path
end

crumb :repository do |repository|
  if repository.persisted?
    link repository.title
  else
    link 'New'
  end
  parent :repositories
end

# COLLECTION

crumb :collections do
  link 'Collections', collections_path
end

crumb :collection do |collection|
  if collection.persisted?
    link collection.display_title
  else
    link 'New'
  end
  parent :collections
end

# ITEM

crumb :items do
  link 'Items', items_path
end

crumb :deleted_items do
  link 'Deleted'
  parent :items
end

crumb :item do |item|
  if item.persisted?
    link(item.title) if item.title # todo item can not have a title...
  else
    link 'New'
  end
  parent :items
end

# USER

crumb :users do
  link 'Users', users_path
end

crumb :user do |user|
  if user.persisted?
    link user.email
  else
    link 'New'
  end
  parent :users
end

# INVITATION

crumb :invitations do
  link 'Invitations', auth_invitations_path
  parent :users
end

crumb :invitation do |user|
  if user.persisted?
    link user.email
  else
    link 'New'
  end
  parent :invitations
end

# BATCH

crumb :batches do
  link 'Batches', batches_path
end

crumb :batch do |batch|
  if batch.persisted?
    link batch.name if batch.name
    parent :batches, batch
  else
    link 'New'
    parent :batches, batch
  end
end

crumb :batch_results do |batch|
    link batch.name, batch_path(batch) if batch.name
    link 'Results'
    parent :batches, batch
end

# BATCH ITEM

crumb :batch_items do |batch|
  link batch.name, batch
  link 'Batch Items', batch_batch_items_path(batch)
  parent :batches
end

crumb :batch_item do |batch_item|
  link batch_item.batch.name, batch_item.batch
  parent :batches
  if batch_item.id
    link batch_item.title
  else
    link 'New'
  end
end

# SUBJECT

crumb :subjects do
  link 'Subjects', subjects_path
end

crumb :subject do |subject|
  if subject.persisted?
    link subject.name
  else
    link 'New'
  end
  parent :subjects
end

# TIME PERIOD

crumb :time_periods do
  link 'Time Periods', time_periods_path
end

crumb :time_period do |time_period|
  if time_period.persisted?
    link time_period.name
  else
    link 'New'
  end
  parent :time_periods
end