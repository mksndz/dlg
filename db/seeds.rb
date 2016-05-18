# Truncate Tables
[
    Subject,
    BatchItem,
    Item,
    User,
    Role,
    Batch,
    Collection,
    Repository
].each do |m|
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{m.table_name} RESTART IDENTITY CASCADE;")
end

# Truncate Other Tables
%w(
    collections_users
    repositories_users
    roles_users
    collections_subjects
    searches
    delayed_jobs
    bookmarks
).each do |j|
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{j} RESTART IDENTITY CASCADE;")
end

#
# Default Subjects for app
#
Subject.create!([
                 { name: 'The Arts' },
                 { name: 'Business & Industry' },
                 { name: 'Education' },
                 { name: 'Folklife' },
                 { name: 'Government & Politic' },
                 { name: 'Land & Resources' },
                 { name: 'Literature' },
                 { name: 'Media' },
                 { name: 'Peoples & Cultures' },
                 { name: 'Religion' },
                 { name: 'Science & Medicine' },
                 { name: 'Sports & Recreation' },
                 { name: 'Transportation' }
             ])

#
# Default Roles for app
#
Role.create!([
                 { name: 'super' },
                 { name: 'coordinator' },
                 { name: 'committer' },
                 { name: 'basic' }
             ])

#
# Initial Super User
#
user = User.create!(
                email: 'mak@uga.edu',
                password: 'password'
             )

user.roles << Role.find_by_name('super')
user.save

#
# Initial Basic User
#
user = User.create!(
                email: 'basic@uga.edu',
                password: 'password'
             )

user.roles << Role.find_by_name('basic')
user.save