module MonthlyBilling
    require "stripe"

	@queue = :monthly_billing
  	def self.perform
  		puts "handling monthly billing"
  		Company.all.each do |c|
            billing_days = c.billing_days_for(1.month.ago)
            if billing_days.count > 0
                pro_users = billing_days.map{|day| day.project_user.user}.compact.uniq
                if pro_users.count > 0
                    if c.customer_id
                        #create an invoice item
                        Stripe::InvoiceItem.create(
                            :customer => c.customer_id,
                            :amount => pro_users.count*2000,
                            :currency => "usd",
                            :description => "#{1.month.ago.beginning_of_month.strftime('%B')} Billing"
                        )
                        puts "#{c.name} pro user count for #{1.month.ago.strftime("%b")}: #{pro_users.count}"
                    else
                        #customer does not have a stripe token. raise some sort of an error
                    end
                end
            end


  		end
  	end
end
