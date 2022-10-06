# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Product.create(name:        "Reformation Cassidy Denim Jumpsuit",
                description:"Reformation Cassidy Denim Jumpsuit in Indio. Size 8. New with tag.",
                price:      19800).image.attach(
                                    io: File.open('app/assets/images/cassidydenimjumpsuit1.png'),
                                    filename: 'cassidydenimjumpsuit1.png',
                                    content_type: 'image/png')