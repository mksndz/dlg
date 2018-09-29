require 'rake'

task fix_hi_repo_relations: :environment do
  start_time = Time.now
  ActiveRecord::Base.connection.execute(
    'TRUNCATE TABLE holding_institutions_repositories RESTART IDENTITY;'
  )
  Repository.all.each do |r|
    hi = HoldingInstitution.find_by_display_name r.title
    if hi
      hi.repositories << r
      hi.save(validates: false)
    else
      puts "No HI for #{r.title}"
    end
  end
  finish_time = Time.now
  puts 'Task complete!'
  puts "Processing took #{finish_time - start_time} seconds."
end