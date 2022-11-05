class Company < ApplicationRecord
  
  validates :name, presence: true, uniqueness: true
  
  has_many_attached :pdf_files

  # this is to get pdf file urls via rails console: Company.first.pdf_file_url
  def pdf_file_urls
    pdf_files.map{|p| Rails.application.routes.url_helpers.url_for(p) }
  end

end
