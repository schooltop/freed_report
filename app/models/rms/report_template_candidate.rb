# To change this template, choose Tools | Templates
# and open the template in the editor.

class Rms::ReportTemplateCandidate
  class << self
    def port_type_candidates
      [["全部","全部"]] + Dic::Type.port_type.dic_codes.collect{|c| [c.code_label, c.id]}
    end

    def sub_type_candidates
      [["全部","全部"]] + Dic::Type.sub_site_type.dic_codes.collect {|c| [c.code_label, c.id]}
    end

    def site_level_candidates
      [["全部","全部"]] + Dic::Type.site_level.dic_codes.collect {|c| [c.code_label, c.id]}
    end

    def project_status_candidates
      [["全部","全部"],["运行状态",0],["试运行状态",1],["工程状态",2]]
    end

    def check_state_candidates
      [["全部","全部"],["已验收",1],["未验收",0]]
    end

    def device_manu_candidates
      [["全部","全部"]] + Dic::Type.device_vendor.dic_codes.collect{|c| [c.code_label, c.id]}
    end

    def device_ap_kind
      [["全部","全部"]] + Dic::Type.ap_type.dic_codes.collect{|c| [c.code_label, c.id]}
    end

    def device_sw_kind
      [["全部","全部"]] + Dic::Type.sw_type.dic_codes.collect{|c| [c.code_label, c.id]}
    end

    def porttype_candidates
      [["全部", "全部"], ["上联端口", 1], ["下联端口", 0]]
    end
    def ap_manu_candidates
      Dic::Type.ap_type.dic_codes
    end
    def report_type_candidates
      [['曲线图',1],['柱状图',2],['饼图',3]]
    end
  end
end
