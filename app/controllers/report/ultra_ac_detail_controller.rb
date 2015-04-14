class Report::UltraAcDetailController < ApplicationController
  def index
    sorts = parse_sort params[:sort]||"accn"
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
      @ac_detail=[]
      if(["xml","csv","tsv"].include?(params[:format]))
          @ac_detail=find_ac_detail(nil,port,time,sort,order,{})
        else
          find_ac_detail(params[:page]||1,port,time,sort,order,{})
        end

    @grid = UI::Grid.new(Rms::UltraAcDetail,@ac_detail)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@ac_detail}
      format.csv {
        columns = Rms::UltraAcDetail.export_ac_detail
        datas = @grid.to_csv(columns) do |col,data|
          case col
         when 'serial' then data['serial'].to_i
          when 'ap_num' then data['ap_num'].to_i
          else
              data[col]
              end
        end
        send_data(datas,:type=>'text/csv;header=persent',:filename => 'ac_detail.csv')
      }
    end
    end
  end

  private
   def find_ac_detail(page=nil,port=nil,time=nil,sort=nil,order=nil,options={})
     if page
      options.update({:page=>page})
      @ac_detail =  Rms::UltraAcDetail.get_ac_detail(port,time,sort,order).paginate options
    else
      @ac_detail =  Rms::UltraAcDetail.get_ac_detail(port,time,sort,order).all options
    end
   end


end
