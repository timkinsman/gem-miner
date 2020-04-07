require 'nokogiri'
require 'mechanize'

agent = Mechanize.new

# Below opens URL requesting password and finds first field and fills in form then submits page.

login = agent.get('https://github.com/login')
login_form = login.forms.first
login_form.field_with(:name => 'login').value="timkinsman"
login_form.field_with(:name => 'password').value="password"
page = agent.submit login_form

# Below will print page showing information confirming that you have logged in.

#pp page

#print agent.get('https://github.com/marketplace?category=code-quality&type=actions').search("h3.h4")[16].text
#print agent.get('https://github.com/marketplace?category=code-quality&type=actions').search("span.text-small")[16].text

# Begin
pp agent.get('https://github.com/marketplace?category=code-quality&type=actions').search("div.px-3")[2].text

# End
pp agent.get('https://github.com/marketplace?category=code-quality&type=actions').search("div.px-3")[21].text