class MailMan < ActionMailer::Base

  default :from => "xyz"
  # Sends an Email reminder to all the users who missed a pickup date
  def send_report()
    recipient = User.current.mail
    subject   = "Checkout Reminder for"
    mail(:to => recipient, :subject => subject)
  end

end