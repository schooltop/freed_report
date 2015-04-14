class Menu

  attr_reader :id, :name, :url

  def initialize(id, name, url)
    @id = id
    @name = name
    @url = url
  end

  def self.all
    [Menu.new('dashboard', I18n.t('home'), '/ultra/ult_report_models'),
      Menu.new('topology', I18n.t('topology'), '/topo'),
      Menu.new('inventory', I18n.t('inventory'), '/inventory/areas'),
      Menu.new('fault', I18n.t('faultmgr'),  '/fault/events'),
      Menu.new('monet', I18n.t('monetmgr'),  '/monet'),
      Menu.new('value', I18n.t('valueanalysis'),'/value/regions/analysis'),
      Menu.new('smart_plan', I18n.t('cw'),'/smart_plan'),
      Menu.new('report', I18n.t('rms'),'/report/common_reports'),
      Menu.new('webgis', I18n.t('webgis'),  '/webgis'),
      Menu.new('system', I18n.t('systemmgr'),'/system/settings'),
    ]
  end


end
