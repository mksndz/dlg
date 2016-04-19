crumb :root do
  link 'Home', root_path
end

crumb :repositories do
  link 'Repositories', repositories_path
end

crumb :collections do
  link 'Collections', collections_path
end

crumb :items do
  link 'Items', items_path
end

crumb :users do
  link 'Users', users_path
end

crumb :roles do
  link 'Roles', roles_path
end

crumb :subjects do
  link 'Subjects', subjects_path
end

crumb :batches_pending do
  link 'Batches', batches_path
  link 'Pending'
end

crumb :batches_committed do
  link 'Batches', batches_path
  link 'Committed'
end

crumb :repository do |repository|
  if repository.persisted?
    link repository.title
  else
    link 'New'
  end
  parent :repositories
end

crumb :collection do |collection|
  if collection.persisted?
    link collection.display_title
  else
    link 'New'
  end
  parent :collections
end

crumb :item do |item|
  if item.persisted?
    link(item.title) if item.title # todo item can not have a title...
  else
    link 'New'
  end
  parent :items
end

crumb :user do |user|
  if user.persisted?
    link user.email
  else
    link 'New'
  end
  parent :users
end

crumb :role do |role|
  if role.persisted?
    link role.name
  else
    link 'New'
  end
  parent :roles
end

crumb :subject do |subject|
  if subject.persisted?
    link subject.name
  else
    link 'New'
  end
  parent :subjects
end

crumb :batch do |batch|
  if batch.persisted?
    link batch.name if batch.name
  else
    link 'New'
  end
  parent :batches
end

crumb :batch_item do |batch_item|
  if batch_item.persisted?
    link(batch_item.title) if batch_item.title
  else
    'New'
  end
  parent batch_item.batch.name if batch.name
end

