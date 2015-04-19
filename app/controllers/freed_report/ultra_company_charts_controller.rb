class  FreedReport::UltraCompanyChartsController < ApplicationController   #前置报表fonsionchart图表配置功能--2014-6-24版--李江锋ljf
  menu_item "SQL报表"
  sidebar "ultra"
  #include DbSql
  include Comment_Module

def list_report_chart
  #图表列表
  @ultra_company_charts=FreedReport::UltraCompanyChart.all
  @grid = UI::Grid.new(FreedReport::UltraCompanyChart, @ultra_company_charts)
end

def change_current_chart_attr
  #切换图类基本属性
  @ultra_company_chart_style=FreedReport::UltraCompanyChartStyle.find(params[:ultra_company_chart_style_id].to_i)
  params[:chart_attributes]=@ultra_company_chart_style.chart_attributes
  render :partial=>"chart_attributes"
end

def change_current_chart_data
  #切换图类数据源
  @db_source=params[:db_source]
  if @db_source=="1"
    #报表sql
    @ult_report_model=FreedReport::UltReportModel.find(params[:ult_report_model_id].to_i)
    params[:chart_sql]=@ult_report_model.str_sql
    render :partial=>"chart_data"
  elsif @db_source=="2"
    #父图sql
    @ultra_company_chart=FreedReport::UltraCompanyChart.find(params[:ultra_company_chart_id].to_i)
    params[:chart_sql]=@ultra_company_chart.chart_sql
    render :partial=>"chart_data"
  end
end

def change_current_chart_demo
   @chart_id=params[:ultra_company_chart_style_id]
    render :partial=>"chart_demo"
end

def page_report_chart
  #报表页面加载图表2014-7-14--李江锋ljf
  @ultra_company_chart=FreedReport::UltraCompanyChart.find(params[:ultra_company_chart_id].to_i)
  send("#{@ultra_company_chart.action_title}") if @ultra_company_chart.action_title
  render :partial => 'freed_report_chart_partial'
end


def check_report_chart
  #图形配置切换
  @ultra_company_chart=FreedReport::UltraCompanyChart.find(params[:ultra_company_chart_id])
  @ult_report_model=@ultra_company_chart.ult_report_model
  #@charts=FreedReport::UltraCompanyChart.find(:all,:conditions=>"id=#{params[:ultra_company_chart_id]} or parent_id=#{params[:ultra_company_chart_id]} or id=#{@chart.parent_id}") if @chart.has_parent_chart?
  params[:ultra_company_chart_style_id]=@ultra_company_chart.ultra_company_chart_style_id
  params[:da_source]=@ultra_company_chart.da_source
  params[:name]=@ultra_company_chart.name
  #params[:ult_report_model_id]=@ultra_company_chart.ult_report_model_id
  #params[:parent_id]=@ultra_company_chart.parent_id
  params[:chart_attributes]=@ultra_company_chart.chart_attributes
  params[:chart_x]=@ultra_company_chart.chart_x
  params[:chart_xs]=@ultra_company_chart.chart_xs
  params[:chart_row]=@ultra_company_chart.chart_row
  #params[:chart_sql]=@ultra_company_chart.chart_sql
  send("#{@ultra_company_chart.action_title}") if @ultra_company_chart.action_title
  render :partial => 'current_report'
end


def add_report_chart
  submenu_item "common_report"
  #配置添加图表
  if params[:ult_report_model_id]
  @ult_report_model = FreedReport::UltReportModel.find(params[:ult_report_model_id].to_i)
  @charts=@ult_report_model.ultra_company_charts
  @ultra_company_chart=@charts[0]
  @ultra_company_chart=FreedReport::UltraCompanyChart.new unless @charts[0]
  @ultra_company_chart=FreedReport::UltraCompanyChart.find(params[:ultra_company_chart_id].to_i) if params[:ultra_company_chart_id]
  elsif params[:ultra_company_chart_id]
  @ultra_company_chart=FreedReport::UltraCompanyChart.find(params[:ultra_company_chart_id].to_i)
  @charts=FreedReport::UltraCompanyChart.find(:all,:conditions=>"id=#{params[:ultra_company_chart_id]} or parent_id=#{params[:ultra_company_chart_id]} or id=#{@ultra_company_chart.parent_id} or parent_id=#{@ultra_company_chart.parent_id}") if @ultra_company_chart.has_parent_chart?
  else
  @ultra_company_chart=FreedReport::UltraCompanyChart.new
  end
  send("#{@ultra_company_chart.action_title}") if @ultra_company_chart.action_title&&@ultra_company_chart.action_title!=""
  params[:ultra_company_chart_style_id]=@ultra_company_chart.ultra_company_chart_style_id
  params[:da_source]=@ultra_company_chart.da_source
  params[:name]=@ultra_company_chart.name
  #params[:ult_report_model_id]=@ultra_company_chart.ult_report_model_id
  #params[:parent_id]=@ultra_company_chart.parent_id
  params[:chart_attributes]=@ultra_company_chart.chart_attributes
  params[:chart_x]=@ultra_company_chart.chart_x
  params[:chart_xs]=@ultra_company_chart.chart_xs
  params[:chart_row]=@ultra_company_chart.chart_row
  params[:chart_sql]=@ultra_company_chart.chart_sql ? @ultra_company_chart.chart_sql : @ult_report_model.str_sql ? @ult_report_model.str_sql : ""
end

def creat_report_chart
  #创建报表图表
  @unit_chart=FreedReport::UltraCompanyChart.find_by_ultra_company_chart_style_id_and_name(params[:ultra_company_chart][:ultra_company_chart_style_id].to_i,params[:name])
  if @unit_chart
    @ultra_company_chart=@unit_chart
  elsif params[:ultra_company_chart_id]
    @ultra_company_chart=FreedReport::UltraCompanyChart.find(params[:ultra_company_chart_id].to_i)
  elsif params[:copy_new]=="1"
    @ultra_company_chart=FreedReport::UltraCompanyChart.new
  else
    @ultra_company_chart=FreedReport::UltraCompanyChart.new
  end
  @ult_report_model=FreedReport::UltReportModel.find(params[:ult_report_model_id].to_i)
  if params[:ultra_company_chart]
  @ultra_company_chart.ultra_company_chart_style_id=params[:ultra_company_chart][:ultra_company_chart_style_id]
  @ultra_company_chart.chart_style_name=FreedReport::UltraCompanyChartStyle.find(params[:ultra_company_chart][:ultra_company_chart_style_id].to_i).chart_style_name
  @ultra_company_chart.chart_category=FreedReport::UltraCompanyChartStyle.find(params[:ultra_company_chart][:ultra_company_chart_style_id].to_i).chart_category
  @ultra_company_chart.da_source=params[:ultra_company_chart][:da_source]
  @ultra_company_chart.ult_report_model_id=params[:ultra_company_chart][:ult_report_model_id] if params[:ultra_company_chart][:ult_report_model_id]
  #@ultra_company_chart.parent_id=params[:ultra_company_chart][:parent_id] if params[:ultra_company_chart][:parent_id]
  end
  @ultra_company_chart.ult_report_model_id=params[:ult_report_model_id] if params[:ult_report_model_id]
  @ultra_company_chart.chart_attributes=params[:chart_attributes] if params[:chart_attributes]
  @ultra_company_chart.name=params[:name]
  @ultra_company_chart.chart_x=params[:chart_x]
  @ultra_company_chart.chart_xs=params[:chart_xs]
  @ultra_company_chart.chart_row=params[:chart_row]
  @ultra_company_chart.chart_sql=params[:chart_sql]
  @ultra_company_chart.save
  @ultra_company_chart.action_title=params[:name]+@ultra_company_chart.id.to_s
  @ultra_company_chart.save
  if params[:ult_report_model_id]
  redirect_to :action=>"add_report_chart",:ult_report_model_id=>params[:ult_report_model_id],:ultra_company_chart_id=>@ultra_company_chart.id
  else
  redirect_to :action=>"add_report_chart",:ultra_company_chart_id=>@ultra_company_chart.id
  end
  
end

def delete_report_chart
  #删除图表配置
  @ultra_company_chart=FreedReport::UltraCompanyChart.find(params[:id].to_i)
  @ultra_company_chart.delete
  redirect_to :action=>"list_report_chart"
end

end