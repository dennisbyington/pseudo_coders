class Company < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_one_attached :pdf_file
  # has_many_attached :pdf_files

  def pdf_file_url
  # def pdf_file_urls
    Rails.application.routes.url_helpers.url_for(pdf_file) if pdf_file.attached?
    # pdf_files.map{|p| Rails.application.routes.url_helpers.url_for(p) }
  end

end
