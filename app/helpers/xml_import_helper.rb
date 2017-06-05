# helper function for XML Import jobs
module XmlImportHelper

  def prepare_item_hash(hash)
    new_hash = {}
    hash.map do |key, element|
      new_hash[key] = if element.is_a? Array
                        flatten_array(element).uniq
                      else
                        element
                      end
    end
    new_hash
  end

  private

  # flattens an array up to 2 levels
  def flatten_array(element)
    element.flatten 2
  end

end