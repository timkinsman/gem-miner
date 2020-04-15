require_relative 'category'
require 'nokogiri'
require 'mechanize'
require 'csv'

abort('usage: ruby gem_miner GH_login GH_pass') unless ARGV.length == 2

agent = Mechanize.new

login = agent.get('https://github.com/login')
login_form = login.forms.first
login_form.field_with(name: 'login').value = ARGV[0]
login_form.field_with(name: 'password').value = ARGV[1]
page = agent.submit login_form

signin_link = agent.get('https://github.com/').search('a.HeaderMenu-link')
abort('unable to login. please try again') unless signin_link.empty?
print 'login successful'

time = Time.new.strftime('%Y-%m-%d')
Dir.mkdir(time) unless Dir.exist?(time)

@category.each do |cat|
  print "\nweb scraping #{cat}..."
  CSV.open("#{time}/#{cat}.csv", 'w') do |csv|
    csv << %w[Action Stars]

    page = agent.get("https://github.com/marketplace?category=#{cat}&type=actions")
    container = page.search('div.col-lg-9')[1].search('div.d-md-flex')[0]
    action_div = container.search('div.px-3')
    (0..(action_div.length - 1)).each do |i|
      csv << [
        action_div[i].search('h3.h4').text,
        action_div[i].search('span.text-small').text.split.first
      ]
    end

    while page.link_with(text: 'Next')
      link = page.link_with(text: 'Next')
      page = link.click
      container = page.search('div.col-lg-9')[1].search('div.d-md-flex')[0]
      action_div = container.search('div.px-3')
      (0..(action_div.length - 1)).each do |i|
        csv << [
          action_div[i].search('h3.h4').text,
          action_div[i].search('span.text-small').text.split.first
        ]
      end
    end
  end
  print 'complete!'
end
