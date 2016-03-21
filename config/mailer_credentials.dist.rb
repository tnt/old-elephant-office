mailer_credentials = {
  :production => {
      :user_name => "hugo@banza.net",
      :password => "bleistift",
      :address => 'zb.goneo.de',
      :enable_starttls_auto => true,
      :port => 587  # optional
  },
  :development => {
      :user_name => "ernst",
      :password => "nix",
      :address => 'zb.goneo.de',
      :enable_starttls_auto => true
  }
}

MAILER_CREDENTIALS = mailer_credentials[Rails.env.to_sym]
