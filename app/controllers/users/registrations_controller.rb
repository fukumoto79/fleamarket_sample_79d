# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  
  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    if params[:sns_auth] == 'true'
      pass = Devise.friendly_token[15,25]
      pass += "1Az"
      params[:user][:password] = pass
      params[:user][:password_confirmation] = pass
    end
    @user = User.new(sign_up_params)
    unless @user.valid?
      flash.now[:alert] = @user.errors.full_messages
      render :new and return
    end
    session["devise.regist_data"] = {user: @user.attributes}
    session["devise.regist_data"][:user]["password"] = params[:user][:password]
    @address = @user.build_postal
    render :new_address
  end

  def create_address
    @user = User.new(session["devise.regist_data"]["user"])
    @address = Postal.new(address_params)
    unless @address.valid?
      flash.now[:alert] = @address.errors.full_messages
      render :new_address and return
    end
    @user.build_postal(@address.attributes)
    # ひとまずカード登録しない場合、カード登録時にスキップ機能を入れるかどうかは後で検討する
    @user.save
    sign_in(:user, @user)
    redirect_to root_path
  end

  def create_creditcard
    # サインアップ認証画面では登録しないことに
    # あっても任意、設定はcardコントローラーで行う
  end

  protected
  
  def configure_sign_up_params
    # デフォルトで入っているemailとpasswordは改めて書く必要がない。deviseが処理する。
    # 追加したカラムのデータのみをパラムスに収めるように記述する
    # imageにデフォルト画像を設定してデータに格納、呼び出す
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :nickname,
      :first_name,
      :family_name,
      :birthday,
      # :image
    ])
  end

  def address_params
    params.require(:postal).permit(:postal_code,
                                    :prefecture,
                                    :city,
                                    :address_line,
                                    :apartment
    )
  end



  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
