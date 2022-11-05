# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

Company.destroy_all

# -----------------------------------------------
# *** SEED DATA WITH ACTIVE STORAGE FILES ***
Company.create!(name: "Seed Company 1")
Company.find(1).pdf_files.attach(io: File.open('../test_files/test_01.pdf'), filename: 'test_01.pdf', content_type: 'application/pdf')
Company.find(1).pdf_files.attach(io: File.open('../test_files/test_04.pdf'), filename: 'test_04.pdf', content_type: 'application/pdf')
Company.create!(name: "Seed Company 2")
Company.find(2).pdf_files.attach(io: File.open('../test_files/test_02.pdf'), filename: 'test_02.pdf', content_type: 'application/pdf')
Company.find(2).pdf_files.attach(io: File.open('../test_files/test_05.pdf'), filename: 'test_05.pdf', content_type: 'application/pdf')
Company.create!(name: "Seed Company 3")
Company.find(3).pdf_files.attach(io: File.open('../test_files/test_03.pdf'), filename: 'test_03.pdf', content_type: 'application/pdf')
Company.find(3).pdf_files.attach(io: File.open('../test_files/test_06.pdf'), filename: 'test_06.pdf', content_type: 'application/pdf')
# -----------------------------------------------

p "Created #{Company.count} companies"
