freed_report
============

a report_chart tool

在开发报表中经常用到图型报表，很苦恼每开发一个报表就得写一个xml图形配置，和数据请求结果集处理方法。结合前段时间的开发经历，今天和大家分享一下，ruby调用fusionchart的接口封装。

先看一下需求原型：《实现首页的多种粒度、多种图形的展现》如图：


技术分析：

接口的实现采用rest的设计原理，结合数据库做持久化配置，统一封装了图表展示需求。即不管请求什么类型的图型报表展示，统一由一个方法处理图型类别判断、和图型结果渲染。达到了只用一个XML文件、一个后台请求方法，实现所有类型图例请求的目标。

对fushionchart在ruby中的渲染需要如下几样东西。

1、数据结果集。2、XLM渲染脚本。

一：首先分析一下数据结果集的封装

创建一个数据库表，部分字段如下：（举例：AC图表的4个粒度的图型配置。）

area_gran	time_gran	action_title	chart_style_id	chart_atrributes	chart_sql	parent

地域粒度	时间力度	连接名称	图表类型	图表属性	图表数据集	父节点

province	day	province_day_ac	1	该图表的配置属性	SQL脚本

province	month	province_month_ac	1	---	---

city        day	city_day_ac	1	---	---	

city	month	city_month_ac	1	---	---

现在假设有一个名称为AC的柱状图的图表需要展示：

由于该图表有省天、省月、地市天、地市月等粒度的切换需求所以，设置了地域粒度（area_gran）、时间粒度（time_gran）字段。

action_title：为方法请求响应名称。由“区域力度+时间力度+请求标识”组成。

chart_style_id：用于关联chart_styles图型类别定义表，该表对所有fusionchart图类及相关属性做了定义。

chart_atrributes：为该图表实例，定义的属性配置。（实例化了chart_styles的具体参数数值）

chart_sql：为图表的数据结果集获取SQL脚本。

parent：此字段的设置是为了结果集的公用，即当两图表在同一个sql中能查处所有两表结果集的话，子表图直接采用父表的结果进行渲染。

（此外还有chart_x（主轴）,chart_sx（附轴）,chart_row（X轴）等字段来定义渲染的列对象。）

准备好数据库配置信息后，页面请求数据结果集就变的很简单了。                

1、页面调用AC图列展示请求代码：

<%freed_report_chart("ac",params[:area_gran],params[:time_gran])%>

注释：freed_report_chart是封装的一个方法，包含三个参数，请求标识（随便取一个标识名称、每一个需求取唯一的名称即可）、当前区域粒度、当前时间粒度。

freed_report_chart代码如下：


def freed_report_chart(kpi_style,area_gran,time_gran)

            @user_analyses=instance_variable_get("@#{area_gran}_#{time_gran}_#{kpi_style}")

            @column=instance_variable_get("@#{area_gran}_#{time_gran}_#{kpi_style}_column")

   if @user_analyses.nil?||@user_analyses.empty?

             concat "<p>没有数据!</p></div>"

   else

            con_name="con_"+kpi_style+"_"+area_gran

            str_xml = render("first_pages/builder/user_data.builder")

            str_xml=CGI.unescapeHTML(str_xml) 

     render_chart '/FusionCharts/'+@column.chart_style_name,'',str_xml,con_name, 590, 280, false, false do

    end

   end

   end


注释：

@user_analyses为获取的整体数据结果集。

@column为对应定义的图形属性实例对象。

render("first_pages/builder/user_data.builder")为XML渲染模版请求@column和@user_analyses共同对次文件渲染。

@column.chart_style_name为图表类型swf类型文件请求名称（例如2D饼图的时候源文件路径为/FusionCharts/Pie2D.swf）。

con_name为将次chart图渲染值某个DIV的自定义id名称。



2、控制层代码分析：


def area_gran_check

  @area_gran=params[:area_gran]

  @kpi_style=params[:kpi_style]

  @time_gran=params[:time_gran]

  combin_name(@kpi_style,@time_gran,@area_gran)

  send(@find_combin_name)

end

def combin_name(kpi_style,time_gran,area_gran)

  @find_combin_name="#{area_gran}_#{time_gran}_#{kpi_style}"

end

注释：

combin_name(@kpi_style,@time_gran,@area_gran)用于拼接请求的图例方法。

send(@find_combin_name)为动态请求拼接出来的方法。（比如请求：province_day_ac、province_day_other）。*：other即代表任何需求标签别名。



3、模型层代码分析：


def method_missing(method_name, *args)

  @method_name=method_name

  @report_source=FreedReport::UltraCompanyChart.find(:first,:conditions=>"action_title='#{@method_name}'")

  if  @report_source

      excute_page_sql(@report_source)

  else

      super

  end

end



注释：页面通过请求province_day_ac在控制层转发了此方法请求到模型层。咱们看到，代码里没有实际的定义province_day_ac、province_day_other这么些方法。按理请求一个没有定义的方法是要报404错误了。这里运用了ruby元编程的动态相应method_missing方法。当所有没有定义的方法请求的时候都会走这个过滤方法，


@method_name对应获取所请求的方法名称，@report_source则通过这个名称巧妙的去刚才定义的数据库表中查找对应action_title字段为该方法的数据库记录。

当然如果查找数据库中，没有定义有该方法的时候会有super发挥404错误页面了，相反，模型层会继续调用excute_page_sql(@report_source)方法来渲染请求的结果集。



def excute_page_sql(exc_object)

      @chart_ult_freed_reports=[]

      @cullent_attributes=@dbh.execute(content_params(exc_object.chart_sql))

      #获取报表展示字段

      @columns=@cullent_attributes.column_names  

      @cullent_attributes.each do |report|

              b={}

              report.each_with_index do |a , x|

                 b[@columns[x]]=a.to_s

              end

              #组装结果集

              @chart_ult_freed_reports<<b

      end

    #图表对象

    instance_variable_set("@#{exc_object.action_title}_column", exc_object)

    #图表数据源

    instance_variable_set("@#{exc_object.action_title}",@chart_ult_freed_reports)

end


注释：def excute_page_sql方法通过method_missing中查找传过来的@report_source对象，获取其中的SQL脚本调用数据库连接执行sql脚本获取数据集结果存放到

instance_variable_set("@#{exc_object.action_title}",@chart_ult_freed_reports)

中供前台响应渲染。其他相印的属性则存放在

instance_variable_set("@#{exc_object.action_title}_column", exc_object)中供xml渲染调用。



数据渲染小结：

我们看到采用rest的设计理念，即你只管请求，我匹配处理，有则回调，无则异常。总共不过50~100行的代码量已经将前台请求到数据封装处理逐一实现了。

不同图型请求，不同图例需求的请求，最终都放到了数据库的直接配置请求中。没有了繁琐的粒度判断，类型判断。



二：XLM渲染脚本封装

由于需求中多次用到图型XML渲染、经过分析，不同图形的XML渲染脚本其实是大同小异的。

XML渲染脚本根据图型的类别需求大致分为如下几样属性：

1：整体图形属性、即图形标题、背景色等的属性参数配置。

2：主轴、附轴的数据获取。

3：X轴列值的获取（其中饼图、只有X轴的列值，不需要柱状图、曲线图一类的主轴、附轴数据集）

我们还记得，页面请求的时候有一个XML渲染文件的调用render("first_pages/builder/user_data.builder")

这个文件通过分别获取后台返回的对象集，分别进行渲染，分别得出所请求的图例。

@user_analyses为获取的整体数据结果集。

@column为对应定义的图形属性实例对象。



XML代码分析：

require "builder"

require "fusioncharts_helper"

xml = Builder::XmlMarkup.new

xml.chart(to_chart_hash(@column.chart_attributes))do

#此部分为X轴列值渲染

   if @column.chart_row&&@column.chart_row!=""

      xml.categories do

        for item in @user_analyses

          xml.category(:name=>item["#{@column.chart_row}"])

        end

      end

   end

   #注释：此部分为主轴数据渲染

  if @column.chart_x&&@column.chart_x!=""

    if @column.chart_category=="pie_chart"

       #注释：饼图渲染

       for columnall in @column.chart_x.split(",")

            column=columnall.split("|")

            xml.set(:name=>"#{column[0]}" , :value=>@user_analyses[0][column[0]],:color=>"#{column[1]}")

       end

    else

   #注释：柱状图、曲线图类数据渲染

      for columnall in @column.chart_x.split(",")

           column=columnall.split("|")

           xml.dataset(:seriesName=>column[0]) do

              for item in @user_analyses

                xml.set(:value=>item[column[0]],:color=>"#{column[1]}")

              end

            end

      end

    end

  end

#注释：此部分为附加轴数据渲染

  if @column.chart_xs&&@column.chart_xs!=""

    for columnall in @column.chart_xs.split(",")

         column=columnall.split("|")

         xml.dataset(:seriesName=>column[0],:parentYAxis=>"S",:color=>"#{column[1]}") do

            for item in @user_analyses

              xml.set(:value=>item[column[0]],:color=>"#{column[1]}")

            end

          end

    end

  end

end



结尾：基于数据库持久化的图表请求到此结束。目前的需求处理实现了：通过前置配置数据库内容即可定制图表报表的展现，初步实现了预期的效果。如果你也喜欢欢迎交流哇。

