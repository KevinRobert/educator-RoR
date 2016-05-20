class MessageMailer < ApplicationMailer

  default to: "admin@smileprep.com"

  def report_message(name, email, message)
    @name = name
    @email = email
    @message = message
    
    mail from: @email, subject: "Message from #{@name}"
  end
end
