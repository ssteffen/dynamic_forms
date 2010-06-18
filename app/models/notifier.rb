class Notifier < ActionMailer::Base
  def new_forms_notification(object, response_id, content)
    recipients  object.email_notification_address
    from        'webmaster@housing.siu.edu'
    subject     object.title + " Form submission."
    body        content
  end
end
