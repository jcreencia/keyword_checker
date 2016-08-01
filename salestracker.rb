require 'csv'

class SalesTracker

	def initialize
		@count = 0
		@gross_sales = 0
		@promo_rebates = 0
		@promo_units = 0
		@promo_cost = 0
		@units_ordered = 0
		@amazon_fees = 0
		@num_of_returns = 0
		@production_cost_per_unit = 4.65
		@inventory_placement_fee = 0
		@other = 0
		@advertising_fee = 0
		@retail_price_per_box = 17.95
	end

	def count(filename)
		CSV.foreach("./#{filename}") do |row|

			@count += 1

		  if @count >= 5
		  	if row[3].include?('Order Payment') && row[4].include?('Product charges')
			  	@gross_sales += convert_to_f(row[6])
			  	@units_ordered += row[7].to_i
			  end

			  if row[3].include?('Order Payment') && row[4].include?('Amazon fees')
			  	@amazon_fees += convert_to_f(row[6])
			  end

			  if row[3].include?('Refund') && row[4].include?('Product charges')
			  	@gross_sales += convert_to_f(row[6])
			  	@num_of_returns += row[7].to_i
			  end

			  if row[3].include?('Refund') && row[4].include?('Amazon fees')
			  	@amazon_fees += convert_to_f(row[6])
			  end

				if row[3].include?('Order Payment') && row[4].include?('Promo rebates')
					rebate = convert_to_f(row[6])
 			  	@promo_rebates += rebate

 			  	if rebate < -15
			  		@promo_units += 1 
			  	end
			  end

			  if row[3].include?('Order Payment') && row[4].include?('Other') && row[5].include?('Shipping')
			  	@other += convert_to_f(row[6])
			  end

			  if row[3].include?('Service Fees') && row[4].include?('Amazon fees') && row[5].include?('FBA Inventory Placement Service Fee')
			  	@inventory_placement_fee += convert_to_f(row[6])
			  end

				if row[3].include?('Service Fees') && row[4].include?('Transaction Details') && row[5].include?('Cost of Advertising')
			  	@advertising_fee += convert_to_f(row[6])
			  end
			  
		  end		  
		end
		
		print
	end

	def print
		puts "--------------------------------"
		puts "Report as of #{Date.today}"
		puts "--------------------------------"
		puts "Units given away: #{@promo_units}"
		puts "Units full price: #{full_price_units_sold - @num_of_returns}"
		puts ""
		puts "Units ordered: #{@units_ordered}"
		puts "Units returned: #{@num_of_returns}"
		puts ""
		puts "Total units sold: #{total_units_sold}"
		puts "Total inventory stock: #{inventory_stock}"
		puts "--------------------------------"
		puts "Gross sales: #{gross_sales}"
		puts "Amazon fees: #{amazon_fees}"
		puts "Promo rebates: #{promo_rebates}"
		puts "Other: #{@other}"
		puts "Inventory placement: #{@inventory_placement_fee}"
		puts "Advertising fee: #{advertising_fee}"
		puts ""
		puts "********************************"
		puts "PAYOUT: #{amazon_payout}"
		puts "********************************"
		puts ""
		puts "Product costs: #{cost_of_goods_sold}"
		puts ""
		puts "--------------------------------"
		puts "PROFIT: #{gross_profit}"
		puts "Margin: #{gross_profit_margin}%"
		puts "--------------------------------"
		puts "Units to sell to break even: #{units_to_breakeven}"
		puts ""
		
	end

	def gross_sales
		@gross_sales.round(2)
	end

	def amazon_fees
		@amazon_fees.round(2)
	end

	def promo_rebates
		@promo_rebates.round(2)
	end

	def advertising_fee
		@advertising_fee.round(2)
	end

	def convert_to_f(price_str)
		price_str.slice!('$')
		price_str.to_f
	end

	def units_to_breakeven
		((5544.15 - amazon_payout) / @retail_price_per_box).round
	end

	def amazon_payout
		(@gross_sales + @amazon_fees + @promo_rebates + @other + @inventory_placement_fee + @advertising_fee).round(2)
	end

	def actual_profit_per_box
		(amazon_payout / full_price_units_sold) - @production_cost_per_unit
	end

	def full_price_units_sold
		@units_ordered - @promo_units
	end

	def inventory_stock
		998 - total_units_sold
	end

	def total_units_sold
		@units_ordered - @num_of_returns
	end

	def gross_profit
		amazon_payout - cost_of_goods_sold
	end

	def gross_profit_margin
		((gross_profit / amazon_payout) * 100).round(2)
	end

	def cost_of_goods_sold
		@production_cost_per_unit * total_units_sold
	end

end


sales_tracker = SalesTracker.new
sales_tracker.count('report.csv')


