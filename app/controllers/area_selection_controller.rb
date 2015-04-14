# To change this template, choose Tools | Templates
# and open the template in the editor.

class AreaSelectionController < ApplicationController
  def domains
    respond_to do |format|
      format.html {
        render :layout=>false
      }
      format.json {
        render :json => Area.domains_tree(current_user,params[:key],params[:domain_dns],params[:expand_level],params[:area_level]),:layout=>false
      }
    end
  end
end
