module Report::PerfTemplatesHelper
  def chart_set(seq)
    @perf_template.chart_sets.select{|c| c.chart_seq.to_i == seq}[0]
  end

  def chart_set_seqs
    @perf_template.chart_sets.collect{|c| c.chart_seq}
  end

  def net_loc
    if !@perf_template.netloc.nil? && !@perf_template.netloc.empty?
      netloc = @perf_template.netloc.split(" and ")
      netloc = netloc.grep /port=|town=|cityid=/
      netloc[0].gsub(/\(|\)/,'') unless netloc.empty?
    end
  end

  def resource_template_dic_groups
    [['device_manu','设备厂家'],['device_type','设备类型'],['port_type','热点类型'],['device_kind','设备型号'],['device_state','使用状态'],['soft_ver','软件版本']]
  end

  def resource_template_dic_group_text(value)
    selected = resource_template_dic_groups.select { |t|  t[0] == value}
    selected[0][1] unless selected.empty?
  end

  def alarm_template_dic_groups
    [['device_manu','设备厂家'],['sender_class','设备类型'],['port_type','热点类型'],['device_type','设备型号'],['alarm_type','告警类型'],['severity_name','告警级别'],['alarm_alias','告警名称']]
  end

  def alarm_template_dic_group_text(value)
    selected = alarm_template_dic_groups.select { |t|  t[0] == value}
    selected[0][1] unless selected.empty?
  end

  def sort_types
    [['升序', 1], ['降序', 2]]
  end

  def sort_type_text(value)
    selected = sort_types.select { |t|  t[1] == value}
    selected[0][0] unless selected.empty?
  end

  def netloc_grans
    [["省份", 0],["地市", 1],["郊县", 2],["AC", 8],["代维厂家", 4],["单位", 3],
      ["热点", 5],
      ["交换机",9],["交换机端口",10],["AP",11]]
  end
  
  def netloc_grans_name(netloc_gran)
    netloc_grans.select{|gran| gran[1] == netloc_gran }[0][0]
  end

  def netloc_grans_text(value)
    selected = netloc_grans.select { |t|  t[1] == value}
    selected[0][0] unless selected.empty?
  end

  def netloc_grans_case
    [["专案组", 0],["专案", 1],["AP", 2]]
  end

  def netloc_grans_case_text(value)
    selected = netloc_grans_case.select { |t|  t[1] == value}
    selected[0][0] unless selected.empty?
  end
  
  def busytimes
    [["全时段",-2],["全网忙时", -1],["指定时段",-3]]
  end
  
  def template_time_types
    [["今天",1],["昨天", 2],["本周",3],["上周",4],["本月",5],["上月",6]]
  end
  
  def busy_times(value)
    [["全时段",-2],["全网忙时", -1],["指定时段",-3]]
  end

  def busytime_text(value)
    selected = busytimes.select { |t|  t[1] == value}
    selected[0][0] unless selected.empty?
  end
  
  def busytime_text2(value,type)
    selected = busy_times(type).select { |t|  t[1] == value}
    selected[0][0] unless selected.empty?
  end

  def time_grans
    [["全部",7],["季度", 0],["月份",1],["周",2],["日期",3],["时段",4],["仅按小时聚合",6]]
  end

  def time_gran_text(value)
    selected = time_grans.select { |t|  t[1] == value}
    selected[0][0] unless selected.empty?
  end

  def dic_group_selections
    selections = {}
    unless @perf_template.group_original.nil?
      group_originals = @perf_template.group_original.split(";")
      group_originals.each do |original|
        originals = original.split("=")
        selections[originals[0].to_sym] = originals[1].split(",").collect{|s| s.to_i}
      end
    end
    selections
  end
end
