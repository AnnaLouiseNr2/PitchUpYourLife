require "pdf/reader"
require "open-uri"
# Service class to extract plain text from a CV PDF attached to an Application.
#
# How it works:
# - Opens the CV file directly from its URL (ActiveStorage/Cloudinary).
# - Uses the PDF::Reader gem to parse the PDF contents.
# - Iterates through each page and concatenates the page text into a single string.
# - Returns the full text of the CV.
#
# How to use:
#   CvTextExtractor.call(application)  # => "full CV text"

class CvTextExtractor
  def self.call(application)
    pdf_file = URI.open(application.cv.url)
    reader = PDF::Reader.new(pdf_file)
    text = ""
    reader.pages.each do |page|
      text << page.text
    end
    text
  end
end
