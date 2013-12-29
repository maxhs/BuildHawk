class UserMailer < ActionMailer::Base
  default from: "will@buildhawk.com"

  def welcome(user)
  	@user = user
  	mail(
      :subject => "Welcome to BuildHawk!",
      :to      => user.email,
      #:from    => "will@buildhawk.com",
      :from    => "max@ristrettolabs.com",
      :tag     => 'Welcome'
    )

  end
end
