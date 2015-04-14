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

  map.namespace :admin do |admin|
    admin.resources :oids
  end

  map.resources :rjb_test
  map.resources :accumulative_user

  map.resources :consistency_check, :collection => {:unique_equipment => :get, :long_down_time => :get, :device_version => :get, :unplan_equipment => :get}

  map.resources :field_validites,:collection => {:update_field_validity => :post}

  map.resources :journals

  map.resources :version_logs

  map.resources :versions

  map.resources :sws

  map.resources :import, :collection => { :import_errors => :get, :index => :get }

  map.resources :aps, :collection => { :export_to_csv => :get,:sure => :get, :unsure => :get }

  map.resources :fit_ap, :collection => { :edit_one => :get, :edit_all => :get, :plan_fat_aps => :get, :import_aps => :get, :destroy_import_aps => :delete, :edit_import_ap => :get }

  map.resources :fat_ap, :collection => { :edit_one => :get, :edit_all => :get }
  
  map.resources :acs, :collection => { :load_script => :post, :delete_script => :delete, :dhcp_ac => :get, :show_task => :get }

  map.resources :export_files, :member => { :download => :get }

  map.resources :batch_discover

  map.resources :Sysnotes

  map.resources :floors

  map.resources :buildings

  map.resources :sites, :collection => { :project_status_warn_or_not => :get, :filter_ac => :get, :filter_college => :get, :filter_starbuck => :get, :download_attachment => :get }

  map.resources :room_off_point

  map.resources :districts

  map.resources :bts 

  map.resources :bts_query

  map.resources :repeater_task

  map.resources :cells , :collection => {:suggest => :get}

  map.resources :repeater_report

  map.resources :repeater_import,:collection => { :import_errors => :get, :index => :get }

  map.resources :trace_libraries,:collection => { :destroy_trace_library => :post }


  map.resources :repeater,:collection => { :options_for_cell => :get, :options_for_bt => :get,:options_for_area_repeater => :get, :temperature_chart => :get, :power_electrical_level_chart => :get, :down_plus_chart => :get}

  map.resources :cities, :collection => {:field_validities_check => :get, :options_for_area => :get , :dn_resources => :get, :destroy_resource => :delete }
  map.resources :mit_cell_port_assoc, :collection => { :change_relation => :get, :show_cell => :get, :show_port => :get}

  map.resources :smart_plan, :collection => {:index => :get, :show => :get, :optimize => :get}

  map.resources :ap_summary, :collection => {:details => :get}

  map.resources :areas

  map.purchase 'inventory/areas', :controller => 'cities'
  map.resources :preferences, :collection => { :dashboard => :post }
  map.resources :roles
  
  map.resources :meas_types

  map.resources :users

  map.resource :session

  map.resources :supplies

  map.resources :profiles

  map.namespace :wifi do |wifi|
    wifi.resources :mobile_units
  end

  map.namespace :fault do |fault|
    fault.resources :events, :collection => { :confirm => :get, :convenient_show => :get, :save_conditions => :get, :remove_conditions => :get, :export_to_csv => :get }
    fault.resources :histories, :collection => { :convenient_show => :get, :ap_fault_histories => :get, :export_to_csv => :get, :ap_details => :get }
    fault.resources :rules, :collection => {:domain=>:get}
    fault.resources :event_classes, :collection => {:edit => :get}
    fault.resources :knowledges 
    fault.resources :summaries
    fault.resources :event_standardizations,  :collection => {:import => :get}
    fault.resources :import_update_fault_sta, :collection => {:import => :get, :do_import => :post}
  end
  map.namespace :security do |sec|
    sec.resources :roles
    sec.resources :domains, :collection => {:domain=>:get}
    sec.resources :sessions
    sec.resources :onling_users
  end
  map.namespace :report do |report|
    report.resources :perf_templates , :collection => {:domains=>:get, :annual_report => :get,:chart=>:get, :kpilist_candidate=>:get}
    report.resources :case_templates , :collection => {:case_tree => :get}
    report.resources :alarm_templates
    report.resources :resource_templates
    report.resources :special,:collection => {:ap_info => :get,:case_user => :get,:delete_ap => :delete}
    report.resources :starbuck_reports
    report.resources :alarm_standard_reports
  end

  map.namespace :system do |sys|
    sys.resources :settings, :collection => {:edit_alarm_filter => :get, :update_alarm_filter => :post, :edit_fields => :get}
    sys.resources :sysparams
  end

  map.namespace :value do |value|
    value.resources :base ,:collection =>{:domain => :get,:hot_type => :get}
    value.resources :aps, :collection => { :analysis => :get, :highvalue => :get, 
      :single_info => :get,:user_num_chart => :get,
      :used_time_chart => :get, :total_traffic_chart => :get,
      :load_time_chart => :get, :user_num_flash => :get,
      :used_time_flash => :get, :total_traffic_flash => :get,
      :load_time_flash => :get
    }
    value.resources :regions, :collection => {:analysis => :get, :rank =>:get, :single_rank=>:get,:single_rank_image=>:get}
    value.resources :hotspots, :collection => { :export_last_week_users => :get, :analysis =>:get, 
      :search_sectors => :get, :single_info => :get,:highvalue => :get,
      :user_num_chart => :get,:used_time_chart => :get,
      :total_traffic_chart => :get, :load_time_chart => :get,
      :highvalue_hot => :get, :highvalue_user => :get,
      :condition => :get, :user_num_flash => :get,
      :used_time_flash => :get, :total_traffic_flash => :get,
      :load_time_flash => :get
    }
    value.resources :cells, :collection => {:analysis =>:get, :search_sectors => :get, :single_info => :get,:highvalue => :get, :user_num_chart => :get,:used_time_chart => :get, :total_traffic_chart => :get, :load_time_chart => :get}
    value.resources :users,:collection =>{:highvalue =>:get,:analysis => :get}
    value.resources :highvalue_condition
    value.resources :single_user, :collection => {:detail => :get, :time_length_chart => :get, :traffic_chart => :get, :time_length_flash => :get, :traffic_flash => :get}
    value.resources :auth_nasids
  end

  map.namespace :logm do |log|
    log.resources :operations
    log.resources :securities
    log.resources :systems
  end

  map.namespace :dic do |dic|
    dic.resources :dic_codes
  end

  map.namespace :inventory do |inventory|
    inventory.resources :param_templates
    inventory.resources :areas, :collection => { :options_for_area => :get }
    inventory.resources :devices, :collection => {:ping=>:get,:discover=>:post}
    inventory.resources :links, :collection => {:options_for_port => :get }
    inventory.resources :configs
    inventory.resources :repeater_query
    inventory.resources :amends,:collection => { :options_for_area => :get, :export => :post , :import => :get, :do_import => :post, :importing => :post, :results => :get }
    inventory.resources :cities,:collection => { :options_for_area => :get }
    inventory.resources :async_tasks, :collection => { :ping => :post , :update_show => :get}
    inventory.resources :colleges
    inventory.resources :starbucks
    inventory.resources :omcs, :collection => { :discover => :post }
    inventory.resources :ap_query, :collection => {:update_rule => :get, :export_to_csv => :get, :sure => :get, :unsure => :get }
    inventory.resources :ac_query, :collection => {:sure => :get, :unsure => :get, :update_state => :get}
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
