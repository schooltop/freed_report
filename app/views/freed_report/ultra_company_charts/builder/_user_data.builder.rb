
require "builder"
require "fusioncharts_helper"
xml = Builder::XmlMarkup.new
xml.chart(to_chart_hash(@column.chart_attributes))do
 
   if @column.chart_row&&@column.chart_row!=""
      xml.categories do
        for item in @user_analyses
          xml.category(:name=>item["#{@column.chart_row}"])
        end
      end
   end

  if @column.chart_x&&@column.chart_x!=""
    if @column.chart_category=="pie_chart"
       for columnall in @column.chart_x.split(",")
            column=columnall.split("|")
            xml.set(:name=>"#{column[0]}" , :value=>@user_analyses[0][column[0]],:color=>"#{column[1]}")
       end
    else
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
