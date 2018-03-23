Rails.application.routes.draw do
  root 'vacancies#index'

  get 'check' => 'application#check'

  resources :vacancies, only: %i[index show]
  resource :sessions, controller: 'hiring_staff/sessions'
  resources :schools, only: %i[index show edit update], controller: 'hiring_staff/schools' do
    resources :vacancies, only: %i[index new create update edit destroy show], controller: 'hiring_staff/vacancies' do
      # Legacy form routing copied over
      get 'review', on: :member
      put 'publish', on: :member
      get 'published', on: :member
      resource :job_specification, only: :show, controller: 'hiring_staff/vacancies', action: :job_specification
      resource :candidate_specification,
               only: :show, controller: 'hiring_staff/vacancies',
               action: :candidate_specification
      resource :application_details, only: :show, controller: 'hiring_staff/vacancies', action: :application_details
    end
    resource :vacancies, only: %i[new create], controller: 'schools/vacancies' do
      get 'step_2', to: 'schools/vacancies#step_2'
      post 'submit_step_2', to: 'schools/vacancies#submit_step_2'
      get 'step_3', to: 'schools/vacancies#step_3'
      post 'submit_step_3', to: 'schools/vacancies#submit_step_3'
    end

    resource :vacancy, only: [] do
      get :job_specification, to: 'vacancies/job_specification#new'
      post :job_specification, to: 'vacancies/job_specification#create'
    end

    resources :vacancies, only: [:show] do
      get 'review', to: 'schools/vacancies#review'
      post 'publish', to: 'schools/vacancies#publish'
    end
  end

  match '*path', to: 'application#not_found', via: %i[get post patch put destroy]
end
