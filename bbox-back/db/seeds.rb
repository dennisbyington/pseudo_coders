# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Company.destroy_all

Company.create!([{
  name: "Seed Company 1"
},
{
  name: "Seed Company 2"
},
{
  name: "Seed Company 3"
}])

p "Created #{Company.count} companies"
