class ChecklistMailer < ActionMailer::Base
    layout "list_mailer"

    def export(recipient_email, item, project)
      @recipient = User.where(:email => recipient_email).first
      @company = @recipient.company
      @logo_url = @company.image.url(:small) if @company.image_file_name
      @recipient = Sub.where(:email => recipient_email).first unless @recipient
      @project = project
      @checklist_item = item
      mail(
          :subject  => "#{project.name} - #{item.body[0..20]}...",
          :to       => recipient_email,
          :from     => "BuildHawk Checklists <support@buildhawk.com>",
          :reply_to => "checklists@buildhawk.com",
          :tag      => 'Checklist Item Export'
      )
    end
end
