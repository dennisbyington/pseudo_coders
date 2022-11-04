# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Company.destroy_all

# -----------------------------------------------
# *** SEED DATA WITH ACTIVE STORAGE FILES ***
Company.create!(name: "Seed Company 1")
Company.find(1).pdf_file.attach(io: File.open('../test_files/test_01.pdf'), filename: 'test_01.pdf', content_type: 'application/pdf')
Company.create!(name: "Seed Company 2")
Company.find(2).pdf_file.attach(io: File.open('../test_files/test_02.pdf'), filename: 'test_02.pdf', content_type: 'application/pdf')
Company.create!(name: "Seed Company 3")
Company.find(3).pdf_file.attach(io: File.open('../test_files/test_03.pdf'), filename: 'test_03.pdf', content_type: 'application/pdf')
# -----------------------------------------------


# -----------------------------------------------
# *** SEED DATA WITHOUT ACTIVE STORAGE FILES ***
# Company.create!([{
#   name: "Seed Company 1"
# },
# {
#   name: "Seed Company 2"
# },
# {
#   name: "Seed Company 3"
# }])
# -----------------------------------------------

p "Created #{Company.count} companies"
