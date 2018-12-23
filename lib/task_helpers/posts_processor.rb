class PostsProcessor 

  require "nokogiri"
  require "open-uri"

  BASE_URL     = "https://www.pravda.com.ua".freeze
  ARCHIVES_URL = "https://www.pravda.com.ua/archives/".freeze

  def initialize(number_of_month:)
    @number_of_month = number_of_month
  end

  def process
    check_input
    get_and_save_posts
  end

  def valid_number_of_month?(number_of_month)
    number_of_month != "0" && number_of_month.to_i < 13
  end

  def check_input
    raise 'Wrong number of month' unless valid_number_of_month?(@number_of_month)
  end

  def date_pattern
    @number_of_month.size == 1 ? "0#{@number_of_month}2018" : "#{@number_of_month}2018" 
  end

  def get_archives_of_2018
    Nokogiri::HTML(open(ARCHIVES_URL))
  end

  def get_links
    get_archives_of_2018.css(".ui-state-default").map{ |item| item[:href] }.compact
      .select{ |item| item.match?(date_pattern) }.map { |item| item.prepend(BASE_URL)}
  end

  def get_articles(link)
    Nokogiri::HTML(open(link)).css(".article-info")
  end

  def article_title(article)
    article.at_css(".article__title a").text
  end

  def article_text(article)
    article.at_css(".article__text").text
  end

  def article_link(article)
    link = article.at_css(".article__title a")[:href]
    link.start_with?('http') ? link : link.prepend(BASE_URL)
  end
  
  def get_and_save_posts
    get_links.each do |link|
      get_articles(link).each do |article|
        Post.create(title: article_title(article), text: article_text(article), link: article_link(article))
      end
    end  
  end
end