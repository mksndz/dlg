# common methods for dealing with fulltext ingestion
class FulltextUtils
  def self.whitelisted(text)
    # match anything that is not a non-printable character
    fulltext_whitelist_regex = /[^[:print:]]/
    # break text into array before removing ctrl chars (newline is a cntrl chr)
    fulltext_lines = text.split("\n")
    fulltext_lines.map { |line| line.gsub!(fulltext_whitelist_regex, ' ') }
    fulltext_lines.join("\n")
  end
end
