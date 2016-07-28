require 'csv'

class SalesTracker

	def initialize
		@count = 0
		@product_charges = 0
		@giveaway_rebates = 0
		@promos = 0
		@promo_cost = 0
		@units_sold = 0
		@amazon_fees = 0
		@num_of_returns = 0
	end

	def count(filename)
		CSV.foreach("./#{filename}") do |row|

			@count += 1

		  if @count >= 5
		  	if row[3].include?('Order Payment') && row[4].include?('Product charges')
			  	@product_charges += convert_to_f(row[6])
			  	@units_sold += row[7].to_i
			  end

			  if row[3].include?('Order Payment') && row[4].include?('Amazon fees')
			  	@amazon_fees += convert_to_f(row[6])
			  end

			  if row[3].include?('Refund') && row[4].include?('Product charges')
			  	@product_charges += convert_to_f(row[6])
			  	@num_of_returns += row[7].to_i
			  end

			  if row[3].include?('Refund') && row[4].include?('Amazon fees')
			  	@amazon_fees += convert_to_f(row[6])
			  end

				if row[3].include?('Order Payment') && row[4].include?('Promo rebates')
					rebate = convert_to_f(row[6])
 			  	@giveaway_rebates += rebate

 			  	if rebate < -15
			  		@promos += 1 
			  	end
			  end

			  if row[3].include?('Order Payment') && row[4].include?('Other')
			  	@product_charges += convert_to_f(row[6])
			  end
		  end		  
		end
		
		print	
	end

	def print
		puts "--------------------------------"
		puts "Report as of #{Date.today}"
		puts "--------------------------------"
		puts "giveaway units: #{@promos}"
		puts "full price units(incl. returns): #{full_price_units_sold - @num_of_returns}"
		puts ""
		puts "units sold: #{@units_sold}"
		puts "units returned: #{@num_of_returns}"
		puts "total units sold: #{total_units_sold}"
		puts ""
		puts "total inventory stock: #{inventory_stock}"
		puts "--------------------------------"
		puts "charges: #{@product_charges.round(2)}"
		puts "giveaway rebates: #{@giveaway_rebates.round(2)}"
		puts "amazon fees: #{@amazon_fees.round(2)}"
		puts "--------------------------------"
		puts "total amazon profit: #{total_profit.round(2)}"
		puts "actual profit per box: #{actual_profit_per_box.round(2)}"
		puts "total actual profit: #{(actual_profit_per_box * full_price_units_sold).round(2)}"	
		puts "--------------------------------"
		puts ""
	end

	def convert_to_f(price_str)
		price_str.slice!('$')
		price_str.to_f
	end

	def total_profit
		@product_charges + @amazon_fees + @giveaway_rebates
	end

	def actual_profit_per_box
		(total_profit / full_price_units_sold) - 4.65
	end

	def full_price_units_sold
		@units_sold - @promos
	end

	def inventory_stock
		998 - total_units_sold
	end

	def total_units_sold
		@units_sold - @num_of_returns
	end

end


sales_tracker = SalesTracker.new
sales_tracker.count('report.csv')

