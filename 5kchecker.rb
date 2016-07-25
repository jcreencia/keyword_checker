require 'capybara'
require 'capybara/poltergeist'

class FiveKChecker
	def initialize
		Capybara.javascript_driver = :poltergeist
		Capybara.register_driver :poltergeist do |app|
  		Capybara::Poltergeist::Driver.new(app, {js_errors: false, timeout: 60})
		end
		@session = Capybara::Session.new(:poltergeist)
		@session.visit "https://www.amazon.com/"
		@indexed = []
		@not_indexed = []
		@count = 0
	end

	def search(keyword)
		@session.fill_in 'twotabsearchtextbox', with: "B01C76D0QU #{keyword}"
		@session.click_button 'Go'
		sleep 1
		if @session.has_content? '1 result for '
			@indexed << keyword
		else
			@not_indexed << keyword
		end
	end

	def search_list(keywords)
		puts "total keywords: #{keywords.length}"
		keywords.each do |keyword|
			search(keyword)
			@count += 1
			p @count
		end
	rescue
		puts 'An error occured. Here is the list so far:'
		print_not_indexed()
	end

	def print
		puts '---------------------'
		puts "INDEXED: #{@indexed.length} found"
		puts '---------------------'
		puts @indexed
		puts '---------------------'
		puts "NOT INDEXED: #{@not_indexed.length} found"
		puts '---------------------'
		puts @not_indexed
		puts '---------------------'
	end

	def print_not_indexed
		puts '---------------------'
		puts "NOT INDEXED: #{@not_indexed.length} found"
		puts '---------------------'
		puts @not_indexed
		puts '---------------------'
	end
end

list = %w(storage box cube basket canvas grey gray white foldable collapsible inch for car 13 13x13 large in 33 cm 33x33 big durable high quality tidy dog toy toys toybox box cat pet baby nursery clothes cotton 3 sprouts polyester shelving unit boxes baskets units rope ikea kallax expedit drona organize shelf organiser organizer books cardboard reinforced square kids children childrens childs child bin bedroom playroom car store laundry office closet bathroom pantry under bed craft crafts college dorm)

checker = FiveKChecker.new
checker.search_list(list)
checker.print_not_indexed()
