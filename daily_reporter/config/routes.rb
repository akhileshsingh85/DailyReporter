# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
get 'daily-report', :to => 'report_generator#index'
post 'daily-report', :to => 'report_generator#index'
get 'generate-report', :to => 'report_generator#get_issue_list_data'
