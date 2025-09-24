require "pdf/reader"
require "stringio"
# Service class to extract plain text from a CV PDF attached to an Application.
#
# How it works:
# - Downloads the CV file content directly using ActiveStorage.
# - Uses the PDF::Reader gem to parse the PDF contents.
# - Iterates through each page and concatenates the page text into a single string.
# - Returns the full text of the CV.
#
# How to use:
#   CvTextExtractor.call(application)  # => "full CV text"

class CvTextExtractor

def self.call(application)
  # Check if CV is attached
  unless application.cv.attached?
    raise "No CV file attached to application"
  end

  # Use ActiveStorage to download the file content directly
  pdf_content = application.cv.download

  # Check if the file content is empty
  if pdf_content.blank?
    raise "CV file is empty or could not be downloaded"
  end

  begin
    reader = PDF::Reader.new(StringIO.new(pdf_content))
    text = ""
    reader.pages.each do |page|
      text << page.text
    end
    text
  rescue PDF::Reader::MalformedPDFError => e
    raise "CV file appears to be corrupted or not a valid PDF: #{e.message}"
  rescue => e
    raise "Error processing CV file: #{e.message}"
  end
end

end
