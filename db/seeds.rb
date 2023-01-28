# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Product.create!(
  name: "Slowtide Tarovine Towel",
  description: "100% cotton beach towel. Dimensions: 38 inches by 68 inches",
  price: 4500,
  number_sold: 0).image.attach(
  io: File.open('app/assets/images/SlowtideTarovineTowel.png'),
  filename: 'SlowtideTarovineTowel.png',
  content_type: 'image/png')

Product.create!(
  name: "Reformation Nadira Dress",
  description: "Luisa print. 100% viscose. Size 10.",
  price: 27800,
  number_sold: 0).image.attach(
  io: File.open('app/assets/images/ReformationNadiraDress.png'),
  filename: 'ReformationNadiraDress.png',
  content_type: 'image/png')

Product.create!(
  name: "Rails Thea Top in Tahiti Stripe",
  description: "55% linen 45% rayon. Size Medium. ",
  price: 14800,
  number_sold: 0).image.attach(
  io: File.open('app/assets/images/RailsTheaTopTahitiStripe.png'),
  filename: 'RailsTheaTopTahitiStripe.png',
  content_type: 'image/png')

Product.create!(
  name: "Shiseido Sunscreen",
  description: "1.7 oz bottle. SPF 50+",
  price: 2500,
  number_sold: 0).image.attach(
  io: File.open('app/assets/images/ShiseidoSunscreen.png'),
  filename: 'ShiseidoSunscreen.png',
  content_type: 'image/png')

Product.create!(
  name: "Tory Burch Perry Tote in Light Umber",
  description: "Leather tote bag with three compartments",
  price: 44800,
  number_sold: 0).image.attach(
  io: File.open('app/assets/images/ToryBurchPerryToteLightUmber.png'),
  filename: 'ToryBurchPerryToteLightUmber.png',
  content_type: 'image/png')

Product.create!(
  name: "Bentgo Salad Container",
  description: "54 ounce salad bowl with a stackable compartment tray. Coastal Aqua Color",
  price: 1499,
  number_sold: 0).image.attach(
  io: File.open('app/assets/images/BentgoSaladCoastalAqua.png'),
  filename: 'BentgoSaladCoastalAqua.png',
  content_type: 'image/png')

Product.create!(
  name: "Lululemon All Day Duffel",
  description: "Dimensions: 18.5 inches x 12.5 inches x 9 inches",
  price: 11200,
  number_sold: 0).image.attach(
  io: File.open('app/assets/images/LuluDuffel1.png'),
  filename: 'LuluDuffel1.png',
  content_type: 'image/png')

Product.create!(
  name: "Madewell Black Overalls",
  description: "Size XS",
  price: 6700,
  number_sold: 0).image.attach(
  io: File.open('app/assets/images/MadewellOveralls1.png'),
  filename: 'MadewellOveralls1.png',
  content_type: 'image/png')

Product.create!(
  name: "Patagonia Black Hole Ultralight Tote Pack",
  description: "100% recycled nylon. 27L capacity. Color: Wavy Blue",
  price: 9900,
  number_sold: 0).image.attach(
  io: File.open('app/assets/images/PatagoniaUltralightToteWavyBlue.png'),
  filename: 'PatagoniaUltralightToteWavyBlue.png',
  content_type: 'image/png')
