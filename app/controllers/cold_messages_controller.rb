class ColdMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_business!
  before_action :require_new_conversation!
  before_action :require_active_subscription!

  def new
    @message = Message.new(conversation: conversation)
  end

  def create
    @message = Message.new(message_params.merge(conversation: conversation, sender: business))
    if @message.save
      redirect_to @message.conversation
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def require_business!
    unless business.present?
      store_location!
      redirect_to new_business_path, notice: I18n.t("errors.business_blank")
    end
  end

  def require_new_conversation!
    redirect_to conversation unless conversation.new_record?
  end

  def require_active_subscription!
    unless current_user.active_business_subscription?
      redirect_to BusinessSubscriptionCheckout.new(current_user, developer: developer).url
    end
  end

  def conversation
    @conversation ||= Conversation.find_or_initialize_by(developer: developer, business: business)
  end

  def developer
    @developer ||= Developer.find(params[:developer_id])
  end

  def business
    current_user.business
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
