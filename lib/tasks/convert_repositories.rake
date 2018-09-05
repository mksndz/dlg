desc 'Create a corresponding Holding Institution record for each Repository'

task convert_repositories: :environment do
  count = 0
  HoldingInstitution.delete_all
  Repository.all.each do |r|
    hi = HoldingInstitution.new
    hi.repositories << r
    hi.display_name = r.title
    hi.save(validate: false)
    puts "Holding Institution created from Repository #{r.title}"
    count += 1
  end
  Collection.all.each do |c|
    c.dcterms_provenance.each do |p|
      if HoldingInstitution.find_by_display_name(p)
        puts "Holding Institution already exists for #{p}"
        next
      end
      Repository.all.each do |r|
        hi = HoldingInstitution.new
        hi.display_name = p
        hi.save(validate: false)
        puts "Holding Institution created for #{p}"
        count += 1
      end
    end
  end
  puts "All done. #{count} Holding Institutions created!"
end