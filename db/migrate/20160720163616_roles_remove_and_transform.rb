class RolesRemoveAndTransform < ActiveRecord::Migration


  def up

    # copy roles to new style
    User.all.each do |u|

      roles = u.roles.pluck('name')

      u.is_super = roles.include? 'super'
      u.is_coordinator = roles.include? 'coordinator'
      u.is_committer = roles.include? 'commiter'
      u.is_uploader = roles.include? 'uploader'

      u.save

    end

    drop_join_table :roles, :users
    drop_table :roles

    change_table :users do |t|
    end

  end

  def down

    create_table :roles do |t|
      t.string :name
      t.timestamps null: false
    end

    # define roles
    Role.create!([
                     { name: 'super' },
                     { name: 'coordinator' },
                     { name: 'committer' },
                     { name: 'uploader' },
                     { name: 'basic' }
                 ])

    # set roles for user
    User.all.each do |u|

      u.roles << Role.find_by_name('super') if u.super?
      u.roles << Role.find_by_name('coordinator') if u.coordinator
      u.roles << Role.find_by_name('committer') if u.committer
      u.roles << Role.find_by_name('uploader') if u.uploader
      u.roles << Role.find_by_name('basic')

      u.save

    end

  end

end
