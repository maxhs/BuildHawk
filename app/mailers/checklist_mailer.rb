class ChecklistMailer < ActionMailer::Base
    layout "list_mailer"

    def export(recipient_email, item, project)
      @recipient = User.where(:email => recipient_email).first
      @recipient = Sub.where(:email => recipient_email).first unless @recipient
      @project = project
      @checklist_item = item
      mail(
          :subject => "#{item.body[0..10]}...",
          :to      => recipient_email,
          :from    => "support@buildhawk.com",
          :tag     => 'Checklist Item Export'
      )
    end
end
