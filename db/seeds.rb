# db/seeds.rb

Plan.create(name: :free)
Plan.create(name: :basic)
Plan.create(name: :gold)

User.create(email: 'joaocarlopa@gmail.com', password: 123456)

# Lista de URLs para popular a tabela de sites
urls = [
  'https://www.google.com',
  'https://www.facebook.com',
  'https://www.twitter.com',
  'https://www.linkedin.com',
  'https://www.github.com',
  'https://www.stackoverflow.com',
  'https://www.reddit.com',
  'https://www.amazon.com',
  'https://www.apple.com',
  'https://www.microsoft.com',
  'https://www.yahoo.com',
  'https://www.netflix.com',
  'https://www.spotify.com',
  'https://www.instagram.com',
  'https://www.pinterest.com',
  'https://www.quora.com',
  'https://www.wordpress.com',
  'https://www.medium.com',
  'https://www.tumblr.com',
  'https://www.gitlab.com',
  'https://www.bitbucket.org',
  'https://www.dropbox.com',
  'https://www.box.com',
  'https://www.slack.com',
  'https://www.asana.com',
  'https://www.trello.com',
  'https://www.atlassian.com',
  'https://www.heroku.com',
  'https://www.digitalocean.com',
  'https://www.vercel.com',
  'https://www.netlify.com',
  'https://www.cloudflare.com',
  'https://www.heroku.com',
  'https://www.mongolab.com',
  'https://www.firebase.google.com',
  'https://www.twilio.com',
  'https://www.paypal.com',
  'https://www.stripe.com',
  'https://www.squarespace.com',
  'https://www.wix.com',
  'https://www.shopify.com',
  'https://www.bigcommerce.com',
  'https://www.wix.com',
  'https://www.woocommerce.com',
  'https://www.weebly.com'
]

# Cria registros de sites no banco de dados
# urls.each do |url|
#   Site.find_or_create_by!(url: url, user: User.first) do |site|
#     # Adicione mais atributos se necessário
#     # site.hostname = URI.parse(url).host
#   end
# end

puts "Created #{Site.count} sites."