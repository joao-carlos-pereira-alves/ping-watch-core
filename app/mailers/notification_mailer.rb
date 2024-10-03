# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  def extract_xlsx(user)
    # Gerar o arquivo Excel
    xlsx = user.create_xlsx_extract_notification_file

    # Anexar o arquivo ao e-mail
    attachments['sites_report.xlsx'] = xlsx.read

    mail(to: user.email, subject: I18n.t('mailers.xlsx_extract_subject'))
  end
end
