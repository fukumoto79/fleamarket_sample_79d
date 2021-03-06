class BuyersController < ApplicationController
  require 'payjp'#Payjpの読み込み
  before_action :set_card, :set_product
  before_action :user_in?, only: [:index]
  before_action :item_sold?, only: [:index, :pay]
  
  def index
    if @card.blank?
      #登録された情報がない場合にカード登録画面に移動
      redirect_to new_card_path
    else
      # Rails.application.credentials.dig(:payjp, :PAYJP_PRIVATE_KEY)
      Payjp.api_key = Rails.application.credentials[:PAYJP_PRIVATE_KEY]
      # Payjp.api_key = ENV['PAYJP_PRIVATE_KEY']
      #保管した顧客IDでpayjpから情報取得
      customer = Payjp::Customer.retrieve(@card.customer_id) 
      #カード情報表示のためインスタンス変数に代入
      @default_card_information = customer.cards.retrieve(@card.card_id)
    end
  end

  def pay
    # Rails.application.credentials.dig(:payjp, :PAYJP_PRIVATE_KEY)
    Payjp.api_key = Rails.application.credentials[:PAYJP_PRIVATE_KEY]
    # Payjp.api_key = ENV['PAYJP_PRIVATE_KEY']
    Payjp::Charge.create(
      :amount => @product.price, #支払金額を引っ張ってくる
      :customer => @card.customer_id,  #顧客ID
      :currency => 'jpy',              #日本円
    )
    redirect_to done_product_buyers_path #完了画面に移動
  end

  def done
    @product_buyers= Product.find(params[:product_id])   
    @product_buyers.update(shipping_status: 1)
  end

  private

  def set_card
    @card = Card.find_by(user_id: current_user.id)
  end

  def set_product
    @product = Product.find(params[:product_id])
  end

  def user_in?
    if @product.user_id == @current_user.id
      redirect_to root_path
    end
  end

  def item_sold?
    if @product.shipping_status.present?
      redirect_to root_path
    end
  end
  
end
