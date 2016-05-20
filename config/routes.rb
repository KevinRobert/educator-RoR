Rails.application.routes.draw do
  root to: 'visitors#index'
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users

  # MathJax
  mathjax 'mathjax'

  # Portal routes
  resources :app, :only => [:index]
  resources :portal, :only => [:index]    
  # Dashboard routes
  resources :dashboard, :only => [:index] do
      collection do
        get :search
        get 'detail/:id' => 'dashboard#detail', :as => 'detail'
      end
  end

  get 'tests/main' => 'tests#main', :as => 'tests_main'
  #get 'progress' => 'portal#progress', :as => 'progress'
  get 'portal/result/:id' => 'portal#result', :as => 'portal_result'

  resources :tests, :only => [:index] do
    get :start
    get :test
    post :submit
    get :finish
    get :continue
  end
  post 'tests/contact' => 'tests#contact', :as => 'tests_contact'

  namespace :admin do
    resources :tests do
      get :search
      patch :update_section
      get :questions
      delete 'question/:question_id' => 'tests#remove_question', :as => 'remove_question'
      get 'question/:question_id' => 'tests#view_question', :as => 'view_question'
    end
    delete 'tests/test_section/:test_section_id' => 'tests#destroy_test_section', :as => 'destroy_test_section'

    resources :users do
      post :disable
    end
    
    resources :schools do
      post :disable
      patch :update_section
    end
    delete 'schools/grade_section/:section_id' => 'schools#destroy_grade_section', :as => 'destroy_grade_section'

    resources :questions do
      collection do
        get 'index/:test_id' => 'questions#index', :as => 'index'
        post 'test/:test_id' => 'questions#to_test', :as => 'test'
      end
    end

    post 'users/import' => 'users#import', :as => 'users_import'
    post 'questions/sort' => 'questions#sort', :as => 'questions_sort'
    post 'questions/import' => 'questions#import', :as => 'questions_import'
    post 'schools/get_sections' => 'schools#get_sections'
    post 'schools/get_grades' => 'schools#get_grades'
    post 'users/get_sections' => 'users#get_sections'

    resources :syllabuses
    post 'questions/get_topics' => 'questions#get_topics'
    post 'questions/get_concepts' => 'questions#get_concepts'
    post 'tests/get_topics' => 'tests#get_topics'

  end

  get 'pages/howitworks' => 'pages#howitworks'

  get 'pages/about' => 'pages#about'

  get 'pages/faq' => 'pages#faq'

  get 'pages/contact' => 'pages#contact'

  get 'pages/careers' => 'pages#careers'

  #catch all 
  match '*path', via: :all, to: 'pages#404'

end