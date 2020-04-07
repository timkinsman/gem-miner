# TODO: check if successful login
# TODO: Refactor to avoid suggested actions clash

require 'nokogiri'
require 'mechanize'
require 'csv'

if ARGV.length != 2
    abort("usage: ruby ./gem-miner _login _password")
end

agent = Mechanize.new

# Below opens URL requesting password and finds first field and fills in form then submits page.

login = agent.get('https://github.com/login')
login_form = login.forms.first
login_form.field_with(:name => 'login').value=ARGV[0]
login_form.field_with(:name => 'password').value=ARGV[1]
page = agent.submit login_form

# Below will print page showing information confirming that you have logged in.

category = [
    "api-management",
    "chat",
    "code-quality",
    "code-review",
    "mobile-ci",
    "container-ci",
    "dependency-management",
    "deployment",
    "ides",
    "learning",
    "localization",
    "mobile",
    "monitoring",
    "project-management",
    "publishing",
    "recently-added",
    "security",
    "support",
    "testing",
    "utilities"
]

for cat in category
    CSV.open("#{cat}.csv", "w") do |csv|
        csv << ["Action", "Stars"]
        page = agent.get("https://github.com/marketplace?category=#{cat}&type=actions")

        # First page

        for i in 2..(page.search("div.px-3").length - 1)
            if i > 21
                break
            end        
            csv << [page.search("div.px-3")[i].search("h3.h4").text, page.search("div.px-3")[i].search("span.text-small").text.split.first]
        end

        # Subsequent pages

        while page.link_with(text: 'Next')
            link = page.link_with(text: 'Next')
            page = link.click
            for i in 2..(page.search("div.px-3").length - 1)
                if i > 21
                    break
                end
                csv << [page.search("div.px-3")[i].search("h3.h4").text, page.search("div.px-3")[i].search("span.text-small").text.split.first]
            end
        end
    end
end