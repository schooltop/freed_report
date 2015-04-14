module AuthorizedSystem 

  protected

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :permit_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :permit_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :permit_required
    #
    def permit_required
      permitted? || permission_denied
    end

    def permitted?
      return true if request.xhr?
      allowed = current_permissions.values.select { |p| (p.controller_name == params[:controller] && p.action_name == params[:action]) }
      allowed.length > 0
    end

    # Accesses the current user from the session.
    # Future calls avoid the database because nil is not equal to false.
    def current_permissions
      unless @current_permissions
        @current_permissions = {}
        default=Permission.default.delete_if { |x| ! ((current_user.role.permissions.collect{|cp| cp.module_name}+["home"]).include?(x.module_name))}
        permissions = current_user.role.permissions +  default
        permissions.each do |p|
          url = '/' + p.controller_name
          url += ('/' + p.action_name) if p.action_name != 'index'
#          puts "**********************URL***********************:"+url.to_s
          @current_permissions[url] = p
        end
      end
      @current_permissions
    end

    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_permissions if base.respond_to? :helper_method
    end

    def permission_denied
       render :status => "403 Forbidden", :text => "403 Forbidden"
    end

end
