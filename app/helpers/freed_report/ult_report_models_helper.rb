module FreedReport::UltReportModelsHelper

  def input_and_select_tag(input_params,select_params,id='0',title="手动输入",&blo)
    selector = capture(&blo)
     concat %!
     <div id='shou_#{id}' style='display: none;'>
      #{text_field_tag input_params.to_sym}
      #{link_to_function '选择', js_show('select_'+id)+js_hide('shou_'+id)+js_blank(input_params)}
     </div>
    <div id='select_#{id}'>
      #{selector}
      #{link_to_function title, js_hide('select_'+id)+js_show('shou_'+id)+js_blank(select_params)}
    </div>
         !, blo.binding
    end

 def kgf(num)
    a="&nbsp;"
    num.to_i.times do
    a=a+"&nbsp;"
    end
    return a
 end

end
