# new job to import XML and create BatchItems
class RecordImporterNew
  def self.perform(batch_import_id)
    batch_import = BatchImport.find batch_import_id

    # parse XML, handling XML errors that can cause total failure
    # support future JSON format here?
    raw_hashes = XmlToHashService.hashes_from batch_import.xml

    # convert array of hashes into #create-able form, handling AR errors
    products = BatchItemFactory.build_from raw_hashes, batch_import.validations?, batch_import.batch

    # build results from factory products
    results = { added: [], failed: [] }
    products.each do |p|
      p.key?(:batch_item) ? results[:added] << p : results[:failed] << p
    end

    batch_import.results = results
    batch_import.completed_at = Time.now
    batch_import.save
  end
end