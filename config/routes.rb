begin
  require File.join(File.dirname(__FILE__), 'ultra_routes')
rescue Exception => e
end
ActionController::Routing::Routes.draw do |map|

   map.namespace :freet_report do |freet_report| #前置报表手动配置相关模块  2013-12-17---李江锋
    freet_report.resources :tabmenus
    freet_report.resources :ult_freed_reports
    freet_report.resources :ult_report_models
  end


  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  #map.register '/register', :controller => 'users', :action => 'create'
  #map.signup '/signup', :controller => 'users', :action => 'new'

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  #map.connect 'hi',:controller=>"dashboard", :action=>"set_sys_statue"
  map.root :controller => "freed_report/ult_report_models"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action.:format'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  merge_ultr_routes(map) if defined? merge_ultr_routes
end
