require 'rake'

task reindex_everything: :environment do

  INDEXED_MODELS = %W(Item Collection)

  start_time = Time.now

  INDEXED_MODELS.each do |model|
    if model.constantize.respond_to? :reindex
      # puts "Found #{model.constantize.all.length} DB entries to Reindex"
      puts "Reindexing #{model}"
      model_start_time = Time.now
      model.constantize.reindex
      model_finish_time = Time.now
      puts "#{model} re-indexed in #{model_finish_time - model_start_time} seconds"
    else
      puts "#{model} is not configured for indexing"
    end

  end

  finish_time = Time.now

  puts 'Re-indexing complete!'
  puts "Re-indexing took #{finish_time - start_time} seconds!"

end