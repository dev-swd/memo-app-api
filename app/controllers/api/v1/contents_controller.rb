class Api::V1::ContentsController < ApplicationController

  # 一覧取得
  # 全件
  def index

    conts = Content
      .select("contents.id, contents.title")
      .order("contents.updated_at")

    render json: { status: 200, contents: conts}

  end

  # 一覧取得
  # 引数：
  #  スコープ： scope
  #  ユーザID： uid
  def index_all

    if params[:scope].blank? || params[:scope] == 'public' then
      conts = Content
        .select("contents.id, contents.title")
        .where(scope: 'public')
        .order("contents.updated_at")
    else
      conts = Content
        .select("contents.id, contents.title")
        .where(scope: params[:scope])
        .where(makeid: params[:uid])
        .order("contents.updated_at")
    end

    render json: { status: 200, contents: conts}

  end

  # 一覧取得
  # 引数：
  #  タイトル： title（部分一致）
  #  スコープ： scope
  #  ユーザID： uid
  def index_wheretitle

    if params[:scope].blank? || params[:scope] == 'public' then
      conts = Content
        .select("contents.id, contents.title")
        .where(scope: 'public')
        .where("contents.title like ?", "%" + params[:title] + "%")
        .order("contents.updated_at")
    else
      conts = Content
        .select("contents.id, contents.title")
        .where(scope: params[:scope])
        .where(makeid: params[:uid])
        .where("contents.title like ?", "%" + params[:title] + "%")
        .order("contents.updated_at")
    end

    render json: { status: 200, contents: conts}

  end

  # 一覧取得
  # 引数：
  #  本文： cont（部分一致）
  #  スコープ： scope(private or public)
  def index_wherecont

    if params[:scope].blank? || params[:scope] == 'public' then
      conts = Content
        .select("contents.id, contents.title")
        .where(scope: 'public')
        .where("contents.content like ?", "%" + params[:cont] + "%")
        .order("contents.updated_at")
    else
      conts = Content
        .select("contents.id, contents.title")
        .where(scope: params[:scope])
        .where(makeid: params[:uid])
        .where("contents.content like ?", "%" + params[:cont] + "%")
        .order("contents.updated_at")
    end

    render json: { status: 200, contents: conts}

  end


  # 一覧取得
  # 引数：
  #  タグ： tag
  def index_wheretag

    if params[:scope].blank? || params[:scope] == 'public' then
      conts = Content
        .select("contents.id, contents.title")
        .joins(:tags)
        .where("contents.scope=?", 'public')
        .where("tags.tag=?", params[:tag])
        .order("contents.updated_at")
    else
      conts = Content
        .select("contents.id, contents.title")
        .joins(:tags)
        .where("contents.scope=?", params[:scope])
        .where("contents.makeid=?", params[:uid])
        .where("tags.tag=?", params[:tag])
        .order("contents.updated_at")
    end

    render json: { status: 200, contents: conts}

  end

  # 個別取得
  def show
    cont = Content.find(params[:id])
    tags = Tag
      .where(content_id: params[:id])
      .order(:updated_at)
    render json: { status: 200, content: cont, tags: tags }
  end

  # 登録
  def create_content
    ActiveRecord::Base.transaction do

      # Contents登録
      cont_param = cont_params[:cont]
      cont = Content.new()
      cont.title = cont_param[:title]
      cont.content = cont_param[:content]
      cont.scope = cont_param[:scope]
      cont.makeid = cont_param[:makeid]
      cont.updateid = cont_param[:updateid]
      cont.save!

      # tags登録
      cont_params[:tags].map do |tag_param|
        tag = Tag.new()
        tag.content_id = cont.id
        tag.tag = tag_param[:tag]
        tag.makeid = cont.makeid
        tag.updateid = cont.updateid
        tag.save!
      end

    end

    render json: { status:200, message: "Create Success!"}

  rescue => e
  
    render json: { status:500, message: "Create Error"}
  
  end
  
  # 更新
  def update_content
    ActiveRecord::Base.transaction do

      # Contents登録
      cont_param = cont_params[:cont]
      cont = Content.find(params[:id])
      cont.title = cont_param[:title]
      cont.content = cont_param[:content]
      cont.scope = cont_param[:scope]
      cont.updateid = cont_param[:updateid]
      cont.save!

      # tags登録
      cont_params[:tags].map do |tag_param|
        if tag_param[:id].blank? then
          tag = Tag.new()
          tag.content_id = cont.id
          tag.tag = tag_param[:tag]
          tag.makeid = cont.makeid
          tag.updateid = cont.updateid
          tag.save!
        else
          tag = Tag.find(tag_param[:id])
          if tag_param[:del].blank? then
            tag.content_id = cont.id
            tag.tag = tag_param[:tag]
            tag.updateid = cont.updateid
            tag.save!
          else
            tag.destroy!
          end
        end
      end
    end

    render json: { status:200, message: "Update Success!"}

  rescue => e
  
    render json: { status:500, message: "Update Error"}
  
  end

  # 削除
  def destroy

    ActiveRecord::Base.transaction do
      cont = Content.find(params[:id])
      cont.destroy!
    end

    render json: { status:200, message: "Delete Success!" }

  rescue => e

    render json: { status:500, message: "Delete Error"}

  end

  private
  def cont_params
    params.permit(cont: [:title, :content, :scope, :makeid, :updateid],
                  tags: [:id, :tag, :del],
    )
  end

end
