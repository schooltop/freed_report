class Report::UltraWlanSiteController < ApplicationController
  menu_item "report"
  sidebar "report"
  def index
  submenu_item "device_rate"
    sorts = parse_sort params[:sort]||"code_name"
    sort=sorts[:name]
    order=sorts[:direction]||"ASC"
    @ultra_wlan_site = []
    @cities = Site.find(:all,:conditions => ["site_type = ? and site_dn like ?", 1,"%#{@current_user.domain.base}"])
    @towns = []
    site_id = Dic::Type.find(:first,:conditions => ["type_name = 'port_type'"]).id
    @site_category = Dic::Code.find(:all,:conditions => ["type_id = #{site_id} and is_valid = 1"]).collect {|c| [c.code_label,c.id]}.sort
    unless params[:ultra_wlan_site].nil?
      @city_id = params[:ultra_wlan_site][:cities]
      @town_id = params[:ultra_wlan_site][:towns]
      city_id = params[:ultra_wlan_site][:cities]
      @towns = Site.find(:all,:conditions => ["site_type = ? and parent_site = ?", 2,"#{city_id}"])
    end
    @acs = Ac.find(:all,:conditions => ["ac_dn like ?","%#{@current_user.domain.base}"]).collect{|c| [c.ac_cn,c.id] }.sort
    if !params[:commit].nil?
      unless params[:ultra_wlan_site].nil?
        if(["xml","csv","tsv"].include?(params[:format]))
          @ultra_wlan_site = find_wlan_site(nil,sort,order,{})
        else
          find_wlan_site(params[:page]||1,sort,order,{})
        end
      end
    end

    @grid = UI::Grid.new(Rms::UltraWlanSite,@ultra_wlan_site)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@ultra_wlan_site}
      format.csv {
        columns = Rms::UltraWlanSite.export_wlan_site
        datas = @grid.to_csv(columns) do |col,data|
            case col
           when 'serial' then data['serial'].to_i
            when 'ac_num' then data['ac_num'].to_i
              when 'ap_num' then data['ap_num'].to_i
                when 'sw_poe_num' then data['sw_poe_num'].to_i
                  when 'sw_con_num' then data['sw_con_num'].to_i
                    when 'oun_num' then data['oun_num'].to_i
            else
              data[col]
            end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'ultra_wlan_site.csv')
      }
    end
  end
private
  def query_con
     @cond=[]
     unless params[:ultra_wlan_site].nil?
      site_query = params[:ultra_wlan_site]
      base = @current_user.domain.base
      city_id = site_query[:cities]
      town_id = site_query[:towns]
      if !town_id.nil? && !town_id.empty?
        town = Site.find(:first,:conditions => ["id = '#{town_id}'"]).site_dn
      elsif !city_id.nil? && !city_id.empty? &&(town_id.nil? || town_id.empty?)
        city = Site.find(:first, :conditions => ["id = '#{city_id}'"]).site_dn
      end
      if site_query[:site_cn].nil?||site_query[:site_cn].empty?
       site_cn=""
      else
       site_cn =" and mit_sites.site_cn like '%#{site_query[:site_cn].strip}%'"
      end
      if site_query[:category].nil?||site_query[:category].empty?
       port_type=""
      else
       port_type =" and mit_sites.port_type=#{site_query[:category]}"
      end
      if site_query[:location].nil?||site_query[:location].empty?
        address=""
      else
        address =" and mit_sites.address like '%#{site_query[:location].strip}%'"
      end
      if site_query[:ac_id].empty?||site_query[:ac_id].nil?
        ac_id=""
      else
        ac_id = " and mit_sites.ac_id=#{site_query[:ac_id]}" 
      end
        if !town_id.nil? && !town_id.empty?
          site_dn =" and mit_sites.site_dn like '%#{town}'"
        elsif !city_id.nil? && !city_id.empty? && (town_id.nil? || town_id.empty?)
          site_dn =" and mit_sites.site_dn like '%#{city}'"
        else
          site_dn = " and mit_sites.site_dn like '%#{base}'" unless base.empty?
        end
      end
       @cond<<site_cn<<port_type<<address<<address<< ac_id<<site_dn
       puts "=========================:"+@cond.to_s
  end
   def find_wlan_site(page=nil,sort=nil,order=nil,options={})
#     yesterday = Date.current - 1.days
#     params[:start_time] ||= yesterday.strftime("%Y-%m-%d")
#     time=params[:start_time] unless params[:start_time].nil?
     query_con
     cond=@cond.to_s
     if page
      options.update({:page=>page})
      @ultra_wlan_site =  Rms::UltraWlanSite.get_wlan_site(sort,order,cond).paginate options
    else
      @ultra_wlan_site =  Rms::UltraWlanSite.get_wlan_site(sort,order,cond).all options
    end
   end
end
