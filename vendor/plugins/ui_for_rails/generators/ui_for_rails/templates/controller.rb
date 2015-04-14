class <%= controller_class_name %>Controller < ApplicationController
  before_filter :clear_params
  # GET /<%= table_name %>
  # GET /<%= table_name %>.xml
  #layout "<%= controller_name %>"
  #sidebar "<%= controller_name %>"
  menu_item "<%= controller_name %>"
  def index
    submenu_item "index"
    params.delete_if { |k,v| v.nil? or v.empty? }
    dictionaries
    if(["xml","csv","tsv"].include?(params[:format]))
      @<%= table_name %> = <%= class_name %>.all query
    else
      @<%= table_name %> = <%= class_name %>.paginate query(:page => params[:page])
    end
    @grid = UI::Grid.new(<%= class_name %>,@<%= table_name %>)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @<%= table_name %> }
      format.tsv { 
      send_data(@grid.to_tsv, :type => 'text/plain; header=present', :filename => '<%= table_name %>.tsv') 
      }
      format.csv { 
      send_data(@grid.to_csv, :type => 'text/csv; header=present', :filename => '<%= table_name %>.csv') 
      }

    end
  end

  # GET /<%= table_name %>/1
  # GET /<%= table_name %>/1.xml
  def show
    @<%= file_name %> = <%= class_name %>.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/new
  # GET /<%= table_name %>/new.xml
  def new
    submenu_item "new"
    @<%= file_name %> = <%= class_name %>.new
    dictionaries

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @<%= file_name %> }
    end
  end

  # GET /<%= table_name %>/1/edit
  def edit
    @<%= file_name %> = <%= class_name %>.find(params[:id])
    dictionaries
  end

  # POST /<%= table_name %>
  # POST /<%= table_name %>.xml
  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = '<%= class_name %>创建成功。'
        format.html { redirect_to(params[:redirect_to] || <%= table_name %>_url) }
        format.xml  { render :xml => @<%= file_name %>, :status => :created, :location => @<%= file_name %> }
      else
        dictionaries
        format.html { render :action => "new" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /<%= table_name %>/1
  # PUT /<%= table_name %>/1.xml
  def update
    @<%= file_name %> = <%= class_name %>.find(params[:id])

    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = '<%= class_name %>更新成功。'
        format.html { redirect_to(params[:redirect_to] || <%= table_name %>_url) }
        format.xml  { head :ok }
      else
        dictionaries
        format.html { render :action => "edit" }
        format.xml  { render :xml => @<%= file_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /<%= table_name %>/1
  # DELETE /<%= table_name %>/1.xml
  def destroy
    #@<%= file_name %> = <%= class_name %>.find(params[:id])
    #@<%= file_name %>.destroy
    ids = params[:id] || params[:ids]
    ids = ids.keys if !ids.nil? and ids.is_a?(Hash)
    flash[:notice] = '删除成功。' if <%= class_name %>.destroy(ids)

    respond_to do |format|
      format.html { redirect_to(params[:redirect_to] || <%= table_name %>_url) }
      format.xml  { head :ok }
    end
  end
  private
  #构造查询条件
  def query options = {}
    order_option options
    options
  end
  #查数据字典
  def dictionaries
  end

  def clear_params
    params.delete_if { |k,v| ["redirect_to", "sort"].include?(k) and (v.nil? or v.empty?) }
  end

end
