class UserMailer < ApplicationMailer
  def welcome(user)
    @name = user.name
    mail(to: user.email, subject: I18n.t('mailers.welcome_subject', product_name: ENV['NAME_PRODUCT']))
  end
end
