# new job to import XML and create BatchItems
class NewRecordImporter
  def self.perform(batch_import_id)
    @batch_import = BatchImport.find batch_import_id
    @results_service = JobResultsService.new @batch_import

    # build array of hashes with BI data
    item_hashes = ItemXmlService.new(
      xml: @batch_import.xml,
      results_service: @results_service
    ).hashes

    # build BatchItems - validation?
    BatchItemBuilder.build_from item_hashes, validate:

    @batch_import.save
  end
end