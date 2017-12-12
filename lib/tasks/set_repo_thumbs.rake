require 'rake'

task set_repo_thumbs: :environment do
  THUMB_BASE = 'http://dlg.galileo.usg.edu/do-th:'.freeze
  Repository.all.each do |r|
    r.remote_thumbnail_url = THUMB_BASE + r.slug
    r.save
    if r.errors.key? :thumbnail
      puts "No thumb found for #{r.slug}"
    else
      puts "Thumb found for #{r.slug} and saved as #{r.thumbnail.current_path}"
    end
  end
end