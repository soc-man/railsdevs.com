class NewBusinessNotification < Noticed::Base
  deliver_by :database
  deliver_by :email, mailer: "AdminMailer", method: :new_business

  param :business

  def title
    t "notifications.new_business", business: business.name
  end

  def url
    business_path(business)
  end

  def business
    params[:business]
  end
end
