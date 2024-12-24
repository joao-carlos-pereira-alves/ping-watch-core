class SiteMailer < ApplicationMailer
  def status_change_email(site, user)
    @site = site
    @status = site.status_label
    @url = site.url
    @hostname = site.hostname

    mail(to: user.email, subject: I18n.t('mailers.site_mailer_subject', hostname: @hostname))
  end

  def extract_xlsx(user)
    # Gerar o arquivo Excel
    xlsx = user.create_xlsx_extract_file

    # Anexar o arquivo ao e-mail
    attachments['sites_report.xlsx'] = xlsx.read

    mail(to: user.email, subject: I18n.t('mailers.xlsx_extract_subject'))
  end
end
