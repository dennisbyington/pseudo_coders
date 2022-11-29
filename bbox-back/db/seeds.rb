# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Company.destroy_all

# *** SEED DATA WITH 100 RANDOM PDFS PER COMPANY (except Company 4) ***
# Source: https://github.com/tpn/pdfs

# -----------------------------------------------
# create company 1
Company.create!(name: "Company 1")

# open company_01_files.txt & read into array
company_01_files = File.open("../company_files/company_01_files.txt")
file_data = company_01_files.readlines.map(&:chomp)
company_01_files.close

# for each file, attach as active storage object
for file in file_data
  Company.find(1).pdf_files.attach(io: File.open("../company_files/company_01_files/#{file}"), filename: "#{file}", content_type: 'application/pdf')
end

# -----------------------------------------------
# create company 2
Company.create!(name: "Company 2")

# open company_02_files.txt & read into array
company_02_files = File.open("../company_files/company_02_files.txt")
file_data = company_02_files.readlines.map(&:chomp)
company_02_files.close

# for each file, attach as active storage object
for file in file_data
  Company.find(2).pdf_files.attach(io: File.open("../company_files/company_02_files/#{file}"), filename: "#{file}", content_type: 'application/pdf')
end

# -----------------------------------------------
# create company 3
Company.create!(name: "Company 3")

# open company_03_files.txt & read into array
company_03_files = File.open("../company_files/company_03_files.txt")
file_data = company_03_files.readlines.map(&:chomp)
company_03_files.close

# for each file, attach as active storage object
for file in file_data
  Company.find(3).pdf_files.attach(io: File.open("../company_files/company_03_files/#{file}"), filename: "#{file}", content_type: 'application/pdf')
end

# -----------------------------------------------
# create company 4
Company.create!(name: "Company 4")

# open company_04_files.txt & read into array
company_04_files = File.open("../company_files/company_04_files.txt")
file_data = company_04_files.readlines.map(&:chomp)
company_04_files.close

# for each file, attach as active storage object
for file in file_data
  Company.find(4).pdf_files.attach(io: File.open("../company_files/company_04_files/#{file}"), filename: "#{file}", content_type: 'application/pdf')
end

# -----------------------------------------------
# success message
p "Created #{Company.count} companies"
