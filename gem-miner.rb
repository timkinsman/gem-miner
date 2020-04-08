require_relative 'category'
require 'nokogiri'
require 'mechanize'
require 'csv'

if ARGV.length != 2
    abort("usage: ruby ./gem-miner github_login github_password")
end

agent = Mechanize.new

# Below opens URL requesting password and finds first field and fills in form then submits page.

login = agent.get('https://github.com/login')
login_form = login.forms.first
login_form.field_with(:name => 'login').value=ARGV[0]
login_form.field_with(:name => 'password').value=ARGV[1]
page = agent.submit login_form

# Below will print page showing information confirming that you have logged in.

if agent.get('https://github.com/').search('a.HeaderMenu-link').length != 0
    abort('unable to login. please try again')
end

print "login successful"

time = Time.new.strftime("%Y-%m-%d")
Dir.mkdir(time) unless Dir.exist?(time)

for cat in @category
    print "\nweb scraping #{cat}..."
    CSV.open("#{time}/#{cat}.csv", "w") do |csv|
        csv << ["Action", "Stars"]

        # First page
        page = agent.get("https://github.com/marketplace?category=#{cat}&type=actions")
        cond = page.search("div.col-lg-9")[1].search("div.d-md-flex")[0].search("div.px-3") # Condense
        for i in 0..(cond.length - 1)  
            csv << [cond[i].search("h3.h4").text, cond[i].search("span.text-small").text.split.first]
        end

        # Subsequent pages
        while page.link_with(text: 'Next')
            link = page.link_with(text: 'Next')
            page = link.click
            cond = page.search("div.col-lg-9")[1].search("div.d-md-flex")[0].search("div.px-3") # Condense
            for i in 0..(cond.length - 1)
                csv << [cond[i].search("h3.h4").text, cond[i].search("span.text-small").text.split.first]
            end
        end
    end
    print "DONE!"
end