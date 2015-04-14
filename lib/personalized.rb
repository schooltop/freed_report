module Personalized
  module Sidebar
    def extension_point(point, context)
      return if $CUSTOMER.nil?
      extension = "/#{$CUSTOMER}/#{point}/sidebar"
      full_extension_path = "#{RAILS_ROOT}/personalized/#{$CUSTOMER}/#{point}/_sidebar.erb"
      render :partial => extension, :locals => {:context => context} if File.exist?(full_extension_path)
    end
  end
end

ActionController::Base.class_eval do
  # Assumes a per-application/request view prioritization, not per-controller
  cattr_accessor :application_view_path
  self.view_paths = %w(app/views
                       personalized).map do |path| Rails.root.join(path).to_s end
end

ActionView::Base.send(:include, Personalized::Sidebar)