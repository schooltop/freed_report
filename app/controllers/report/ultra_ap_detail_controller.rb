class Report::UltraApDetailController < ApplicationController
  def index
    sorts = parse_sort params[:sort]||"apcn"
    sort=sorts[:name]
    p "**********************:sort:#{sort}"
    order=sorts[:direction]||"ASC"
    port=params[:id]
    time=params[:time]
    yesterday = Date.current - 1.days
    if time.nil?||time.empty?
      time=yesterday.strftime("%Y-%m-%d")
    end

    p  "*************:port:#{port},time:#{time}"
    unless port.nil?
      @ap_detail=[]
      if(["xml","csv","tsv"].include?(params[:format]))
          @ap_detail=find_ap_detail(nil,port,time,sort,order,{})
        else
          find_ap_detail(params[:page]||1,port,time,sort,order,{})
        end

    @grid = UI::Grid.new(Rms::UltraApDetail,@ap_detail)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@ap_detail}
      format.csv {
        columns = Rms::UltraApDetail.export_ap_detail
        datas = @grid.to_csv(columns) do |col,data|        
         case col
         when 'serial' then data['serial'].to_i
          else
              data[col]
              end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'ap_detail.csv')
      }
    end
    end
  end

  private
   def find_ap_detail(page=nil,port=nil,time=nil,sort=nil,order=nil,options={})
     if page
      options.update({:page=>page})
      @ap_detail =  Rms::UltraApDetail.get_ap_detail(port,time,sort,order).paginate options
    else
      @ap_detail =  Rms::UltraApDetail.get_ap_detail(port,time,sort,order).all options
    end
   end

end
