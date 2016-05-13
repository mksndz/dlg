require 'rake'
require 'open-uri'
require 'nokogiri'

task import_items: :environment do

  start_time = Time.now

  puts 'Clearing out old Items...'
  Item.destroy_all
  Sunspot.commit_if_dirty
  puts 'Items destroyed!'

  meta_xml_root_url = 'http://dlg.galileo.usg.edu/xml/dcq/'

  def exit_with_error(msg = nil)
    puts msg || 'Something unexpected happened...'
    abort
  end

  def set_field_value(field, value = nil)
    @new_item[field.to_sym] = value
  end

  def set_array_field_value(field, value = nil)
    set_field_value field, value.strip.split("\n")
  end

  def set_boolean_field_value(field, value = nil)
    set_field_value field, value == 'true' ? true : false
  end

  exit_with_error 'No Repositories yet in the system!' unless Repository.first
  exit_with_error 'No Collection yet in the system!' unless Collection.first

  Collection.all.each do |collection|

    collection_start_time = Time.now

    xml_url = "#{meta_xml_root_url}#{collection.repository.slug}_#{collection.slug}.xml"
    puts "Importing Items from XML: #{xml_url}"

    @data = Nokogiri::HTML(open(xml_url))

    unless @data.is_a? Nokogiri::HTML::Document
      exit_with_error "Could'nt get valid XML from #{data_source}"
    end

    items = @data.css('item')
    items_in_file = items.length
    puts "File has #{items_in_file} records"
    processed = 0

    items.each do |item|
      puts "Importing Item #{item.css('slug').first.inner_text}"
      processed += 1
      @new_item = Item.new
      Item.column_types.each do |k,v|
        # puts 'field: ' + k
        if item.css(k).first
          val = item.css(k).first.inner_text
        else
          val =  ''
        end
        # puts 'node: ' + item.css(k).inspect
        # puts 'val: ' + val
        if v.is_a? ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array
          set_array_field_value(k, val)
        elsif v.is_a? ActiveRecord::Type::Boolean
          set_boolean_field_value(k, val)
        else
          set_field_value k, val
        end
      end
      @new_item.collection = collection
      @new_item.save(validate: false)
      # puts @new_item.inspect
      puts "Processed #{processed} of #{items_in_file}"
    end
    collection_finish_time = Time.now
    puts "Importing #{xml_url} took #{collection_finish_time - collection_start_time} seconds!"
  end

  Sunspot.commit

  finish_time = Time.now

  puts 'Item importing complete!'
  puts "Processing took #{finish_time - start_time} seconds!"

end