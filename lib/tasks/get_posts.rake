desc "get posts by month"
task :get_posts, [:month] => :environment do |t, args|
  require "nokogiri"
	require "open-uri"

	base = "https://www.pravda.com.ua"
	url = "https://www.pravda.com.ua/archives/"

	if args.month.size == 1 && args.month != "0"
		prop_month = "0#{args.month}2018"
	elsif args.month.size == 2 && args.month.to_i < 13
		prop_month = "#{args.month}2018"
	else
		raise 'Wrong number of month'
	end 

	archives_2018 = Nokogiri::HTML(open(url))

	links = archives_2018.css(".ui-state-default").map{ |item| item[:href] }.compact.select{ |item| item.match?(prop_month) }.map { |item| item.prepend(base)}

	links.each do |link|
	articles = Nokogiri::HTML(open(link)).css(".article-info")
	articles.each do |article|
			link = article.at_css(".article__title a")[:href]
			link.prepend(base) unless link.start_with?('http')
			title = article.at_css(".article__title a").text
			text = article.at_css(".article__text").text
			Post.create(title: title, text: text, link: link)
		end
	end
end