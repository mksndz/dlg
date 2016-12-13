# Truncate Tables
[
    ItemVersion,
    TimePeriod,
    Subject,
    Portal,
    PortalRecord,
    BatchItem,
    Item,
    User,
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
    collections_subjects
    searches
    delayed_jobs
    bookmarks
).each do |j|
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{j} RESTART IDENTITY CASCADE;")
end

#
# DLG Portals
#
Portal.create!([
                { name: 'The Digital Library of Georgia', code: 'dlg' },
                { name: 'The Civil War in the American South', code: 'amso' },
                { name: 'The Civil Rights Digital Library', code: 'crdl' },
                { name: 'Other', code: 'other' },
               ])

#
# Default Subjects
#
Subject.create!([
                 { name: 'The Arts' },
                 { name: 'Business & Industry' },
                 { name: 'Education' },
                 { name: 'Folklife' },
                 { name: 'Government & Politics' },
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
# Default Time Periods
#
TimePeriod.create!([
                 { name: 'Archaeology & Early History' },
                 { name: 'Colonial Era', start: 1733, finish: 1775 },
                 { name: 'Revolution & Early Republic', start: 1775, finish: 1800 },
                 { name: 'Antebellum Era', start: 1800, finish: 1860 },
                 { name: 'Civil War & Reconstruction', start: 1861, finish: 1877 },
                 { name: 'Late Nineteenth Century', start: 1877, finish: 1900 },
                 { name: 'Progressive Era to World War II', start: 1900, finish: 1945 },
                 { name: 'Civil Rights & Sunbelt Georgia', start: 1945, finish: 1980 },
                 { name: 'Georgia at the Turn of the Millennium', start: 1990 },
             ])

#
# Initial Super User
#
User.create!(
                email: 'super@uga.edu',
                password: 'password',
                is_super: true
             )

#
# Initial Basic User
#
User.create!(
                email: 'basic@uga.edu',
                password: 'password'
             )