Rails.application.routes.draw do
# 追加された記述を削除(/api/v1/配下に記述)
#  mount_devise_token_auth_for 'User', at: 'auth'

  namespace :api do
    namespace :v1 do

      # /api/v1/authでアクセス可能
      mount_devise_token_auth_for 'User', at: 'auth'

      resources :contents do
        member do
          patch :update_content
        end
        collection do
          post :create_content
          get :index_all
          get :index_wheretitle
          get :index_wherecont
          get :index_wheretag
        end
      end

    end
  end
end
