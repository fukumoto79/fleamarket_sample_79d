class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update]
  before_action :set_category, only: [:index, :edit, :show, :new, :create, :update, :destroy]
  before_action :item_sold?, only: [:edit]
  before_action :confirm_user_id, only: [:edit, :update, :destroy]


  def index
    @product = Product.all.limit(4).order(created_at: :desc)
  end

  def new
    @product = Product.new
    @product.images.new

    if user_signed_in?
      new_product_path
    else
      redirect_to new_user_session_path
    end
  end

  def create
    @product = Product.create(product_params)
    if @product.save
      redirect_to root_path
    else
      render :new
    end
    # Comment
    @comment = Comment.create(comment_params)
    @product = Product.find(params[:product_id])
  end

  # product#showの画面からedit, destroyアクションを選べる様にする仕様で作成します
  def edit
    #@productに紐づくカテゴリデータ
    @level3 = @product.category
    @level2 = @level3.parent
    @level1 = @level2.parent
    #その分類の一覧ary
    @category_level1 = Category.find(params[:id])
    @category_level2 = @product.category.parent.parent.children
    @category_level3 = @product.category.parent.children
    @tax = @product.price / 10
    @profit = @product.price - @tax
  end
  
  def update
    # binding.pry
    if @product.update(update_params)
      redirect_to product_path
    else
      @category_level2 = @product.category.parent.parent.children
      @category_level3 = @product.category.parent.children
      render :edit
    end
  end

  def show
    @products = Product.all.limit(3)

    @comment = Comment.new
    @commentALL = @product.comments
  end

  def destroy
    product=Product.find(params[:id])
    if product.destroy
      redirect_to root_path, notice: '削除しました'
    else
      render :edit
    end
  end

  def top
  end

  def search_level2
    respond_to do |format|
      format.html
      format.json
        set_category_level2
    end
  end

  def search_level3
    respond_to do |format|
      format.html
      format.json
        set_category_level3
    end
  end

  # 子供のカテゴリーを設定、親の名称で検索 => 紐づいた配列を取得
  # コントロール自体はJSONで行う
  def set_category_level2
    @category_level2 = Category.find(params[:level1_id]).children
  end
  # 孫のカテゴリーを設定
  def set_category_level3
    @category_level3 = Category.find("#{params[:level2_id]}").children
  end

  private
  def product_params
    params.require(:product).permit(:pname,
    :explanation, :status,
    :size_id, :category_id,
    :brand, :shipping_status,
    :deliver, :prefecture,
    :shipping_dates, :price,
    images_attributes: [:image]
  ).merge(user_id: current_user.id)
  end

  # Comment
  private
  def comment_params
    params.require(:comment).permit(:comment).merge(user_id: current_user.id, item_id: params[:item_id])
  end

  def set_product
    @product = Product.find(params[:id])
  end
  
  def update_params
    params.require(:product).permit(
      :pname, :explanation, 
      :status, :size_id, 
      :category_id, :brand, 
      :shipping_status, :deliver, 
      :prefecture, :shipping_dates, 
      :price,
      images_attributes: [:image, :_destroy, :id])
  end

  # デフォルトで設定するセレクトドロップダウンリストに入れる値(親要素の値)を定義
  def set_category
    @category_level1_array = Category.where(ancestry: nil)
  end

  def item_sold?
    if @product.shipping_status.present?
      redirect_to root_path
    end
  end

  def confirm_user_id
    if current_user.id != @product.user_id
      redirect_to root_path
    end
  end

end
