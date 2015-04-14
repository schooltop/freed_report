class Report::UltraOnuDetailController < ApplicationController
  def index
  sorts = parse_sort params[:sort]||"site_city"
    sort=sorts[:name]
    p "**********************:sort:#{sort}"
    order=sorts[:direction]||"ASC"
  port=params[:id]
    unless port.nil?
      @onu_detail=[]
      if(["xml","csv","tsv"].include?(params[:format]))
          @onu_detail=find_onu_detail(nil,port,sort,order,{})
        else
          find_onu_detail(params[:page]||1,port,sort,order,{})
        end

    @grid = UI::Grid.new(Rms::UltraOnuDetail,@onu_detail)
      respond_to do |format|
      format.html #index.html.erb
      format.json {render :json =>@onu_detail}
      format.csv {
        columns = Rms::UltraOnuDetail.export_onu_detail
        datas = @grid.to_csv(columns) do |col,data|
        case col
         when 'serial' then data['serial'].to_i    
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
   def find_onu_detail(page=nil,port=nil,sort=nil,order=nil,options={})
     if page
      options.update({:page=>page})
      @onu_detail =  Rms::UltraOnuDetail.get_onu_detail(port,sort,order).paginate options
    else
      @onu_detail =  Rms::UltraOnuDetail.get_onu_detail(port,sort,order).all options
    end
   end
end
