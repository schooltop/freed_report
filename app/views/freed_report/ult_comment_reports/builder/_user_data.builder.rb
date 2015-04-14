# To change this template, choose Tools | Templates
# and open the template in the editor.

require "builder"
require "fusioncharts_helper"
xml = Builder::XmlMarkup.new
xml.chart(:caption=>'caption_name',:yAxisName=>'units')do
  xml.categories do
    for item in arr_data
      xml.category(:name=>item.citycn)
    end
  end

      xml.dataset(:seriesName=>'用户总数') do
        for item in arr_data
          xml.set(:value=>item.usertotalnum,:color=>'419BBA')
        end
      end

      xml.dataset(:seriesName=>'关联用户数') do
        for item in arr_data
          xml.set(:value=>item.relsucessnum,:color=>'90AD90')
        end
      end

      xml.dataset(:seriesName=>'使用用户数') do
        for item in arr_data
          xml.set(:value=>item.usingusernum,:color=>'B8F2D5')
        end
      end

      xml.dataset(:seriesName=>'校园用户数') do
        for item in arr_data
          xml.set(:value=>item.schoolusernum,:color=>'AA4643')
        end
      end

      xml.dataset(:seriesName=>'公众用户数') do
        for item in arr_data
          xml.set(:value=>item.publicusernum,:color=>'D8D8F5')
        end
      end

      xml.dataset(:seriesName=>'电脑用户数') do
        for item in arr_data
          xml.set(:value=>item.computerusernum,:color=>'AE850A')
        end
      end

      xml.dataset(:seriesName=>'手机用户数') do
        for item in arr_data
          xml.set(:value=>item.mobileusernum,:color=>'A64285')
        end
      end
end
