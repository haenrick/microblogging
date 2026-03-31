class PushSubscriptionsController < ApplicationController
  def create
    sub = Current.user.push_subscriptions.find_or_initialize_by(endpoint: params[:endpoint])
    sub.assign_attributes(p256dh_key: params[:p256dh], auth_key: params[:auth])
    sub.save!
    head :created
  rescue ActionController::ParameterMissing, ActiveRecord::RecordInvalid
    head :unprocessable_entity
  end

  def destroy
    Current.user.push_subscriptions.find_by(id: params[:id])&.destroy
    head :no_content
  end
end
