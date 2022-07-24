require 'YAML'
require 'active_record'
require 'faker'

config = YAML.load_file('config.yml')
ActiveRecord::Base.establish_connection(adapter: config['adapter'], database: config['database'])

Dir["#{File.dirname(__FILE__)}/seeds/*.rb"].each { |file| require file }

Faker::Config.locale = :ja

# rubocop:disable Metrics/BlockLength
ActiveRecord::Base.transaction do
  # write test data below

  (0..99).each do |n|
    Staff.create!(
      code: (10_000 + n).to_s,
      name: Faker::Name.unique.name
    )
  end
  staffs = Staff.all

  (0..99).each do |n|
    Customer.create!(
      code: (10_000 + n).to_s,
      name: Faker::Name.unique.name,
      address: Faker::Address.full_address,
      phone_number: Faker::PhoneNumber.cell_phone,
      staff_code: staffs[rand(99)].code
    )
  end
  customers = Customer.all

  (0..9).each do |n|
    Goods.create!(
      code: (30_000 + n).to_s,
      name: Faker::Game.unique.title,
      price: Faker::Number.within(range: 100..10_000)
    )
  end
  goods = Goods.all

  (0..4).each do |n|
    Depot.create!(
      code: (40_000 + n).to_s,
      name: Faker::Address.unique.city
    )
  end
  depots = Depot.all

  orders = []
  order_details = []
  orders = (0..9999).map do |n|
    Order.new(
      code: n.to_s,
      date: Faker::Date.between(from: '2021-09-01', to: Date.today),
      customer_code: customers[rand(98)].code
    )
  end
  orders.each do |order|
    detail_count = Faker::Number.within(range: 1..3)
    detail_goods = goods.order('RANDOM()').limit(detail_count)
    order_details = (0..detail_count - 1).map do |nn|
      OrderDetail.new(
        order_code: order.code,
        sequence: nn + 1,
        goods_code: detail_goods[nn].code,
        quantity: Faker::Number.within(range: 1..100)
      )
    end
  end
  order_details.map(&:save!)
  orders.map(&:save!)

  depots.each do |depot|
    goods.each do |g|
      next if rand(2).zero?

      quantity = Faker::Number.within(range: 100..10_000)
      Stock.create!(
        depot_code: depot.code,
        goods_code: g.code,
        quantity: quantity
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
