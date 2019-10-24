# common methods for dealing with fulltext ingestion
class FulltextUtils
  def self.whitelisted(text)
    fulltext_whitelist_regex = /[^0-9a-z\s\[\]—\-"$&£()\/*._%©]/i
    # break text up into array before clearing control chars, as newline is a
    # control char :/
    fulltext_lines = text.gsub(
      fulltext_whitelist_regex, ' '
    ).split("\n")
    fulltext_lines.map { |line| line.gsub!(/[[:cntrl:]]/, ' ') }
    # match anything that is not a non-printable character or a whitespace char
    fulltext_whitelist_regex = /[^[:print:]\s]/
    # break text into array before removing ctrl chars (newline is a cntrl chr)
    fulltext_lines = text.split("\n")
    fulltext_lines.map { |line| line.gsub!(fulltext_whitelist_regex, ' ') }
    fulltext_lines.join("\n")
  end
end
