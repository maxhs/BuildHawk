class UserMailer < ActionMailer::Base

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
