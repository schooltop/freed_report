class Report::ImportantReportController < ApplicationController
  menu_item "report"
  sidebar "report"
  submenu_item "import"

  
  def index
  @base = params[:base]
  @base =@current_user.domain.base if @base.blank?
  puts "**********************base:#{@base}"
  end
#ap日报控制层
  def wlan_ap_pref
    yesterday = Date.current - 1.days
    params[:begin_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:end_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:page] ||= 1
    begin_time=params[:begin_time]
    end_time=params[:end_time]
    sorts = parse_sort params[:sort]||"sampledate"
    sort=sorts[:name]
    order=sorts[:direction]||"ASC"
     @ap_pref_data=[]
        if(["xml","csv","tsv"].include?(params[:format]))
          @ap_pref_data=find_ap_data(nil,begin_time,end_time,{},sort,order)
        else
          find_ap_data(params[:page]||1,begin_time,end_time,{},sort,order)
        end

    @grid = UI::Grid.new(Rms::UltraWlanAp,@ap_pref_data)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@ap_pref_data}
      format.csv {
        columns = Rms::UltraWlanAp.export_ap_data
        datas = @grid.to_csv(columns) do |col,data|
            case col
            when 'sampledate' then data['sampledate'].strftime("%Y-%m-%d")
            when 'max_online_rate' then data['max_online_rate'].to_i
            when 'max_conncet_rate' then data['max_conncet_rate']
            when 'busyap_num' then data['busyap_num'].to_i
            when 'ap_num' then data['ap_num'].to_i
            when 'userdown_max_rate' then data['userdown_max_rate'].to_i
            else
              data[col]
            end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'ap_pref_data.csv')
      }
    end
  end
#ac日报控制层
  def wlan_ac_pref
    yesterday = Date.current - 1.days
    params[:begin_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:end_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:page] ||= 1
    sorts = parse_sort params[:sort]||"sampledate"
    sort=sorts[:name]
    order=sorts[:direction]||"ASC"
    begin_time=params[:begin_time]
    end_time=params[:end_time]
     @ac_pref_data=[]
        if(["xml","csv","tsv"].include?(params[:format]))
          @ac_pref_data=find_ac_data(nil,begin_time,end_time,{},sort,order)
        else
          find_ac_data(params[:page]||1,begin_time,end_time,{},sort,order)
        end

    @grid = UI::Grid.new(Rms::UltraWlanAp,@ac_pref_data)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@ac_pref_data}
      format.csv {
        columns = Rms::UltraWlanAp.export_ac_data
        datas = @grid.to_csv(columns) do |col,data|
            case col
            when 'sampledate' then data['sampledate'].strftime("%Y-%m-%d")
            else
              data[col]
            end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'ac_pref_data.csv')
      }
    end
  end
#ac展现日报控制层
  def wlan_ac_show_pref
    yesterday = Date.current - 1.days
    params[:begin_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:end_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:page] ||= 1
    sorts = parse_sort params[:sort]||"sampledate"
    sort=sorts[:name]
    order=sorts[:direction]||"ASC"
    begin_time=params[:begin_time]
    end_time=params[:end_time]
    p "********************:#{end_time}"
     @ac_show_pref_data=[]
        if(["xml","csv","tsv"].include?(params[:format]))
          @ap_show_pref_data=find_ac_show_data(nil,begin_time,end_time,{},sort,order)
        else
          find_ac_show_data(params[:page]||1,begin_time,end_time,{},sort,order)
        end

    @grid = UI::Grid.new(Rms::UltraWlanAp,@ac_show_pref_data)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@ac_show_pref_data}
      format.csv {
        columns = Rms::UltraWlanAp.export_ac_show_data
        datas = @grid.to_csv(columns) do |col,data|
            case col
            when 'ac_rxtyte' then data['ac_rxtyte'].to_i
            when 'ac_txtyte' then data['ac_txtyte'].to_i
            when 'sampledate' then data['sampledate'].strftime("%Y-%m-%d")
            when 'ac_max_user' then data['ac_max_user'].to_i
            when 'ac_max_asso' then data['ac_max_asso'].to_i
            else
              data[col]
            end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'ac_show_pref_data.csv')
      }
    end
  end
#portradius月报报控制层
  def wlan_portal_radius_pref
#    month_time= Date.current - 1.month
#    params[:begin_time] ||= month_time.at_beginning_of_month.strftime("%Y-%m-%d")
#    params[:end_time] ||= month_time.at_end_of_month.strftime("%Y-%m-%d")
   params[:page] ||= 1
   params[:year]||="2012"
   params[:month]||="11"
   begin_time=params[:year]+params[:month]
   puts "*************begin_time:#{begin_time}"
    sorts = parse_sort params[:sort]||"sampledate"
    sort=sorts[:name]
    order=sorts[:direction]||"ASC"
    @years=Rms::UltraWlanAp.get_years
#    begin_time=params[:begin_time]
#    end_time=params[:end_time]
     @portal_data=[]
        if(["xml","csv","tsv"].include?(params[:format]))
          @portal_data=find_portal_data(nil,begin_time,{},sort,order)
        else
          find_portal_data(params[:page]||1,begin_time,{},sort,order)
        end

    @grid = UI::Grid.new(Rms::UltraWlanAp,@portal_data)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@portal_data}
      format.csv {
        columns = Rms::UltraWlanAp.export_portal_data
        datas = @grid.to_csv(columns) do |col,data|
            case col
            when 'sampledate' then data['sampledate'].strftime("%Y-%m-%d")
            when 'regist_num' then data['regist_num'].to_i
            when 'active_num' then data['active_num'].to_i
            when 'req_time' then data['req_time'].to_i
            else
              data[col]
            end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'portal_data.csv')
      }
    end
  end

#重庆portal——radius日报(只有重庆升级)
  def cq_portal_radius
    yesterday = Date.current - 1.days
    params[:begin_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:end_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:page] ||= 1
    sorts = parse_sort params[:sort]||"riqi"
    sort=sorts[:name]
    order=sorts[:direction]||"ASC"
    begin_time=params[:begin_time]
    end_time=params[:end_time]
     @cq_radius_data=[]
        if(["xml","csv","tsv"].include?(params[:format]))
          @cq_radius_data=find_cq_radius_data(nil,begin_time,end_time,{},sort,order)
        else
          find_cq_radius_data(params[:page]||1,begin_time,end_time,{},sort,order)
        end
    @grid = UI::Grid.new(Rms::UltraRptWlanQualityDay,@cq_radius_data)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@cq_radius_data}
      format.csv {
        columns = Rms::UltraRptWlanQualityDay.export_cq_portal_data
        datas = @grid.to_csv(columns) do |col,data|
            case col
            when 'riqi' then data['riqi'].strftime("%Y-%m-%d")
            else
              data[col]
            end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'cq_portal_data.csv')
      }
    end
  end
#===================================================================月===============================================================
# AP月报
  def wlan_ap_pref_month
#    month_time= Date.current - 1.month
#    params[:begin_time] ||= month_time.at_beginning_of_month.strftime("%Y-%m-%d")
#    params[:end_time] ||= month_time.at_end_of_month.strftime("%Y-%m-%d")
    params[:page] ||= 1
   params[:year]||="2012"
   params[:month]||="11"
#    end_time=params[:end_time]
    begin_time=params[:year]+params[:month]
      puts "*************begin_time:#{begin_time}"
    sorts = parse_sort params[:sort]||"sampledate"
    sort=sorts[:name]
    order=sorts[:direction]||"ASC"
    @years=Rms::UltraWlanAp.get_years
     @ap_pref_month_data=[]
        if(["xml","csv","tsv"].include?(params[:format]))
          @ap_pref_month_data=find_ap_month_data(nil,begin_time,{},sort,order)
        else
          find_ap_month_data(params[:page]||1,begin_time,{},sort,order)
        end

    @grid = UI::Grid.new(Rms::UltraWlanAp,@ap_pref_month_data)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@ap_pref_month_data}
      format.csv {
        columns = Rms::UltraWlanAp.export_ap_data
        datas = @grid.to_csv(columns) do |col,data|
            case col
            when 'sampledate' then data['sampledate'].strftime("%Y-%m-%d")
            when 'max_online_rate' then data['max_online_rate'].to_i
            when 'max_conncet_rate' then data['max_conncet_rate']
            when 'busyap_num' then data['busyap_num'].to_i
            when 'ap_num' then data['ap_num'].to_i
            when 'userdown_max_rate' then data['userdown_max_rate'].to_i
            else
              data[col]
            end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'ap_pref_month_data.csv')
      }
    end
  end
#ac月报
  def wlan_ac_pref_month
#    month_time= Date.current - 1.month
#    params[:begin_time] ||= month_time.at_beginning_of_month.strftime("%Y-%m-%d")
#    params[:end_time] ||= month_time.at_end_of_month.strftime("%Y-%m-%d")
   params[:page] ||= 1
   params[:year]||="2012"
   params[:month]||="11"
   begin_time=params[:year]+params[:month]
   puts "*************begin_time:#{begin_time}"
    sorts = parse_sort params[:sort]||"sampledate"
    sort=sorts[:name]
    order=sorts[:direction]||"ASC"
#    begin_time=params[:begin_time]
#    end_time=params[:end_time]
@years=Rms::UltraWlanAp.get_years
     @ac_pref_month_data=[]
        if(["xml","csv","tsv"].include?(params[:format]))
          @ac_pref_month_data=find_ac_month_data(nil,begin_time,{},sort,order)
        else
          find_ac_month_data(params[:page]||1,begin_time,{},sort,order)
        end

    @grid = UI::Grid.new(Rms::UltraWlanAp,@ac_pref_month_data)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@ac_pref_month_data}
      format.csv {
        columns = Rms::UltraWlanAp.export_ac_month_data
        datas = @grid.to_csv(columns) do |col,data|
            case col
            when 'sampledate' then data['sampledate'].strftime("%Y-%m-%d")
            else
              data[col]
            end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'ac_month_data.csv')
      }
    end
  end
#ac展现月报
  def wlan_ac_show_pref_month
#    month_time= Date.current - 1.month
#    params[:begin_time] ||= month_time.at_beginning_of_month.strftime("%Y-%m-%d")
#    params[:end_time] ||= month_time.at_end_of_month.strftime("%Y-%m-%d")
    params[:page] ||= 1
   params[:year]||="2012"
   params[:month]||="11"
   begin_time=params[:year]+params[:month]
   puts "*************begin_time:#{begin_time}"
    sorts = parse_sort params[:sort]||"sampledate"
    sort=sorts[:name]
    order=sorts[:direction]||"ASC"
#    begin_time=params[:begin_time]
#    end_time=params[:end_time]
#    p "********************:#{end_time}"
    @years=Rms::UltraWlanAp.get_years
     @ac_show_month_data=[]
        if(["xml","csv","tsv"].include?(params[:format]))
          @ac_show_month_data=find_ac_month_show_data(nil,begin_time,{},sort,order)
        else
          find_ac_month_show_data(params[:page]||1,begin_time,{},sort,order)
        end

    @grid = UI::Grid.new(Rms::UltraWlanAp,@ac_show_month_data)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@ac_show_month_data}
      format.csv {
        columns = Rms::UltraWlanAp.export_ac_month_show_data
        datas = @grid.to_csv(columns) do |col,data|
            case col
            when 'sampledate' then data['sampledate'].strftime("%Y-%m-%d")
            when 'ac_rxtyte'  then data[':ac_rxtyte'].to_i
            when 'ac_rxtyte'  then data[':ac_rxtyte'].to_i
            when 'ac_max_user' then data['ac_max_user'].to_i
            when 'ac_max_asso' then data['ac_max_asso'].to_i
            else
              data[col]
            end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'ac_show_month_data.csv')
      }
    end
  end

#luhao 2013/9/16 增加1.各地市WLAN业务AP性能统计报表(日)
def wlan_ap_pref_city_d
    yesterday = Date.current - 1.days
    params[:begin_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:end_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:page] ||= 1
    begin_time=params[:begin_time]
    end_time=params[:end_time]
    sorts = parse_sort params[:sort]||"sampledate"
    sort=sorts[:name]
    order=sorts[:direction]||"ASC"
     @ap_pref_data_city_d=[]
        if(["xml","csv","tsv"].include?(params[:format]))
          @ap_pref_data_city_d=find_ap_data_city_d(nil,begin_time,end_time,{},sort,order)
        else
          find_ap_data_city_d(params[:page]||1,begin_time,end_time,{},sort,order)
        end
        p "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&:#{@ap_pref_data_city_d}"
    @grid = UI::Grid.new(Rms::UltraWlanAp,@ap_pref_data_city_d)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@ap_pref_data_city_d}
      format.csv {
        columns = Rms::UltraWlanAp.export_ap_perf_city
        datas = @grid.to_csv(columns) do |col,data|
            case col
            when 'sampledate' then data['sampledate'].strftime("%Y-%m-%d")
            when 'max_online_rate' then data['max_online_rate'].to_i
            when 'max_conncet_rate' then data['max_conncet_rate']
            when 'busyap_num' then data['busyap_num'].to_i
            when 'ap_num' then data['ap_num'].to_i
            when 'userdown_max_rate' then data['userdown_max_rate'].to_i
            else
              data[col]
            end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'ap_pref_data_city_d.csv')
      }
    end
  end

#luhao 2013/9/17 增加2.各地市WLAN业务AC性能统计报表(日)
  def wlan_ac_pref_city_d
    yesterday = Date.current - 1.days
    params[:begin_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:end_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:page] ||= 1
    sorts = parse_sort params[:sort]||"sampledate"
    sort=sorts[:name]
    order=sorts[:direction]||"ASC"
    begin_time=params[:begin_time]
    end_time=params[:end_time]
     @ac_pref_data_city_d=[]
        if(["xml","csv","tsv"].include?(params[:format]))
          @ac_pref_data_city_d=find_ac_data_city_d(nil,begin_time,end_time,{},sort,order)
        else
          find_ac_data_city_d(params[:page]||1,begin_time,end_time,{},sort,order)
        end
    @grid = UI::Grid.new(Rms::UltraWlanAp,@ac_pref_data_city_d)
    p "@grid:#{@grid}"
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@ac_pref_data_city_d}
      format.csv {
        columns = Rms::UltraWlanAp.export_ac_data_city
        datas = @grid.to_csv(columns) do |col,data|
            case col
            when 'sampledate' then data['sampledate'].strftime("%Y-%m-%d")
            else
              data[col]
            end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'ac_pref_data_city_d.csv')
      }
    end
  end

  #luhao 2013/9/18 增加3.各地市WLAN业务展现AC性能统计报表(日)
  def wlan_ac_show_pref_city_d
    yesterday = Date.current - 1.days
    params[:begin_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:end_time] ||= yesterday.strftime("%Y-%m-%d")
    params[:page] ||= 1
    sorts = parse_sort params[:sort]||"sampledate"
    sort=sorts[:name]
    order=sorts[:direction]||"ASC"
    begin_time=params[:begin_time]
    end_time=params[:end_time]
    p "********************:#{end_time}"
     @ac_show_pref_data_city_d=[]
        if(["xml","csv","tsv"].include?(params[:format]))
          @ap_show_pref_data_city_d=find_ac_show_data_city_d(nil,begin_time,end_time,{},sort,order)
        else
          find_ac_show_data_city_d(params[:page]||1,begin_time,end_time,{},sort,order)
        end

    @grid = UI::Grid.new(Rms::UltraWlanAp,@ac_show_pref_data_city_d)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@ac_show_pref_data_city_d}
      format.csv {
        columns = Rms::UltraWlanAp.export_ac_show_data_city
        datas = @grid.to_csv(columns) do |col,data|
            case col
            when 'ac_rxtyte' then data['ac_rxtyte'].to_i
            when 'ac_txtyte' then data['ac_txtyte'].to_i
            when 'sampledate' then data['sampledate'].strftime("%Y-%m-%d")
            when 'ac_max_user' then data['ac_max_user'].to_i
            when 'ac_max_asso' then data['ac_max_asso'].to_i
            else
              data[col]
            end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'ac_show_pref_data_city_d.csv')
      }
    end
  end

#luhao 2013/9/21 增加4.各地市WLAN业务AP性能统计报表(月)
  def wlan_ap_pref_city_m
#    month_time= Date.current - 1.month
#    params[:begin_time] ||= month_time.at_beginning_of_month.strftime("%Y-%m-%d")
#    params[:end_time] ||= month_time.at_end_of_month.strftime("%Y-%m-%d")
    params[:page] ||= 1
   params[:year]||="2012"
   params[:month]||="11"
#    end_time=params[:end_time]
    begin_time=params[:year]+params[:month]
      puts "*************begin_time:#{begin_time}"
    sorts = parse_sort params[:sort]||"sampledate"
    sort=sorts[:name]
    order=sorts[:direction]||"ASC"
    @years=Rms::UltraWlanAp.get_years
     @ap_pref_data_city_m=[]
        if(["xml","csv","tsv"].include?(params[:format]))
          @ap_pref_data_city_m=get_ap_perf_city_m(nil,begin_time,{},sort,order)
        else
          get_ap_perf_city_m(params[:page]||1,begin_time,{},sort,order)
        end

    @grid = UI::Grid.new(Rms::UltraWlanAp,@ap_pref_data_city_m)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@ap_pref_data_city_m}
      format.csv {
        columns = Rms::UltraWlanAp.export_ap_perf_city
        datas = @grid.to_csv(columns) do |col,data|
            case col
            when 'sampledate' then data['sampledate'].strftime("%Y-%m-%d")
            when 'max_online_rate' then data['max_online_rate'].to_i
            when 'max_conncet_rate' then data['max_conncet_rate']
            when 'busyap_num' then data['busyap_num'].to_i
            when 'ap_num' then data['ap_num'].to_i
            when 'userdown_max_rate' then data['userdown_max_rate'].to_i
            else
              data[col]
            end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => '@ap_pref_data_city_m.csv')
      }
    end
  end
  #luhao 2013/9/18 增加5.各地市WLAN业务AC性能统计报表(月)
   def wlan_ac_pref_city_m
#    month_time= Date.current - 1.month
#    params[:begin_time] ||= month_time.at_beginning_of_month.strftime("%Y-%m-%d")
#    params[:end_time] ||= month_time.at_end_of_month.strftime("%Y-%m-%d")
   params[:page] ||= 1
   params[:year]||="2012"
   params[:month]||="11"
   begin_time=params[:year]+params[:month]
   puts "*************begin_time:#{begin_time}"
    sorts = parse_sort params[:sort]||"sampledate"
    sort=sorts[:name]
    order=sorts[:direction]||"ASC"
#    begin_time=params[:begin_time]
#    end_time=params[:end_time]
     @years=Rms::UltraWlanAp.get_years
     @ac_pref_data_city_m=[]
        if(["xml","csv","tsv"].include?(params[:format]))
          @ac_pref_data_city_m=find_ac_data_city_m(nil,begin_time,{},sort,order)
        else
          find_ac_data_city_m(params[:page]||1,begin_time,{},sort,order)
        end

    @grid = UI::Grid.new(Rms::UltraWlanAp,@ac_pref_data_city_m)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@ac_pref_data_city_m}
      format.csv {
        columns = Rms::UltraWlanAp.export_ac_data_city
        datas = @grid.to_csv(columns) do |col,data|
            case col
            when 'sampledate' then data['sampledate'].strftime("%Y-%m-%d")
            else
              data[col]
            end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'ac_perf_data_city_m.csv')
      }
    end
  end


  private
   def find_ap_data(page=nil,begin_time=nil,end_time=nil,options={},sort=nil,order=nil)
     if page
      options.update({:page=>page})
      @ap_pref_data =  Rms::UltraWlanAp.get_data_set(begin_time,end_time,sort,order).paginate options
    else
      @ap_pref_data =  Rms::UltraWlanAp.get_data_set(begin_time,end_time,sort,order).all options
    end
   end

   def find_ac_data(page=nil,begin_time=nil,end_time=nil,options={},sort=nil,order=nil)
     if page
      options.update({:page=>page})
      @ac_pref_data =  Rms::UltraWlanAp.get_ac_data_set(begin_time,end_time,sort,order).paginate options
    else
      @ac_pref_data =  Rms::UltraWlanAp.get_ac_data_set(begin_time,end_time,sort,order).all options
    end
   end

   def find_ac_show_data(page=nil,begin_time=nil,end_time=nil,options={},sort=nil,order=nil)
     if page
      options.update({:page=>page})
      @ac_show_pref_data =  Rms::UltraWlanAp.get_ac_show_data_set(begin_time,end_time,sort,order).paginate options
    else
      @ac_show_pref_data =  Rms::UltraWlanAp.get_ac_show_data_set(begin_time,end_time,sort,order).all options
    end
   end

   def find_portal_data(page=nil,begin_time=nil,options={},sort=nil,order=nil)
     if page
      options.update({:page=>page})
      @portal_data =  Rms::UltraWlanAp.get_portal_data_set(begin_time,sort,order).paginate options
    else
      @portal_data =  Rms::UltraWlanAp.get_portal_data_set(begin_time,sort,order).all options
    end
   end

   def find_cq_radius_data(page=nil,begin_time=nil,end_time=nil,options={},sort=nil,order=nil)
     if page
      options.update({:page=>page})
      @cq_radius_data =Rms::UltraRptWlanQualityDay.get_cq_portal_data(begin_time,end_time,sort,order).paginate options
    else
      @cq_radius_data =Rms::UltraRptWlanQualityDay.get_cq_portal_data(begin_time,end_time,sort,order).all options
    end
   end
#==========================================================================月=============================================================================
   def find_ap_month_data(page=nil,begin_time=nil,options={},sort=nil,order=nil)
     if page
      options.update({:page=>page})
      @ap_pref_month_data =  Rms::UltraWlanAp.get_month_data_set(begin_time).paginate options
    else
      @ap_pref_month_data =  Rms::UltraWlanAp.get_month_data_set(begin_time).all options
    end
   end

   # AC性能报表统计月表
   def find_ac_month_data(page=nil,begin_time=nil,options={},sort=nil,order=nil)
     if page
      options.update({:page=>page})
      @ac_pref_month_data =  Rms::UltraWlanAp.get_ac_month_data_set(begin_time,sort,order).paginate options
    else
      @ac_pref_month_data =  Rms::UltraWlanAp.get_ac_month_data_set(begin_time,sort,order).all options
    end
   end

   #业务展现AC性能统计月表
   def find_ac_month_show_data(page=nil,begin_time=nil,options={},sort=nil,order=nil)
     if page
      options.update({:page=>page})
      @ac_show_month_data =  Rms::UltraWlanAp.get_ac_show_month_set(begin_time,sort,order).paginate options
    else
      @ac_show_month_data =  Rms::UltraWlanAp.get_ac_show_month_set(begin_time,sort,order).all options
    end
   end
   #luhao 2013/9/16 各地市WLAN业务AP性能统计报表(日)
    def find_ap_data_city_d(page=nil,begin_time=nil,end_time=nil,options={},sort=nil,order=nil)
     if page
      options.update({:page=>page})
      @ap_pref_data_city_d =  Rms::UltraWlanAp.get_ap_data_city_d(begin_time,end_time,sort,order).paginate options
    else
      @ap_pref_data_city_d =  Rms::UltraWlanAp.get_ap_data_city_d(begin_time,end_time,sort,order).all options
    end
   end
    #luhao 2013/9/17 各地市WLAN业务AC性能统计报表(日)
    def find_ac_data_city_d(page=nil,begin_time=nil,end_time=nil,options={},sort=nil,order=nil)
     if page
      options.update({:page=>page})
      @ac_pref_data_city_d =  Rms::UltraWlanAp.get_ac_data_city_d(begin_time,end_time,sort,order).paginate options
    else
      @ac_pref_data_city_d =  Rms::UltraWlanAp.get_ac_data_city_d(begin_time,end_time,sort,order).all options
    end
   end
    #luhao 2013/9/18 各地市WLAN业务展现AC性能统计报表(日)
   def find_ac_show_data_city_d(page=nil,begin_time=nil,end_time=nil,options={},sort=nil,order=nil)
     if page
      options.update({:page=>page})
      @ac_show_pref_data_city_d =  Rms::UltraWlanAp.get_ac_show_data_city_d(begin_time,end_time,sort,order).paginate options
    else
      @ac_show_pref_data_city_d =  Rms::UltraWlanAp.get_ac_show_data_city_d(begin_time,end_time,sort,order).all options
    end
   end
    #luhao 2013/9/21 各地市WLAN业务AP性能统计报表(月)
   def get_ap_perf_city_m(page=nil,begin_time=nil,options={},sort=nil,order=nil)
     if page
      options.update({:page=>page})
      @ap_pref_data_city_m =  Rms::UltraWlanAp.get_ap_perf_city_m(begin_time).paginate options
    else
      @ap_pref_data_city_m =  Rms::UltraWlanAp.get_ap_perf_city_m(begin_time).all options
    end
   end
     #luhao 2013/9/17 各地市WLAN业务AC性能统计报表(月)
   def find_ac_data_city_m(page=nil,begin_time=nil,options={},sort=nil,order=nil)
     if page
      options.update({:page=>page})
      @ac_pref_data_city_m=  Rms::UltraWlanAp.get_ac_perf_data_city_m(begin_time,sort,order).paginate options
    else
      @ac_pref_data_city_m =  Rms::UltraWlanAp.get_ac_perf_data_city_m(begin_time,sort,order).all options
    end
   end

end
