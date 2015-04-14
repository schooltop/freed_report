# UI
module UI
  class UI

    # class variables
    @@src_root = File.join(File.dirname(__FILE__),'/../ui')

    @@task_root = File.join(File.dirname(__FILE__),'/../build')

    @@config_src = "#{RAILS_ROOT}/config/ui.yml"
    @@config_yml = $asset_builder_config_yml ||
    (File.exists?(@@config_src) ? YAML.load_file(@@config_src) : nil)

    @@targets = @@config_yml&&@@config_yml["targets"] ? @@config_yml["targets"] : []
    # singleton methods
    class << self
      #复制css,js源码到#{RAILS_ROOT}/public/ui 并创建 #{RAILS_ROOT}/config/ui.yml以供自定义合并规则
      def init
        unless File.exists?(@@config_src)
          init!
        else
          p "config/ui.yml already exists. Aborting task..."
        end
      end     
      def init!
        yml = File.join(@@task_root,'ui.yml')


        content = 'no'

        File.open(yml,"r"){|out|
          content = out.read
        }
        File.open(@@config_src, "w") do |out|
          out.write content
        end

        p @@config_src+" created!"
        migrate
      end
      #迁移 更新 脚本到public
      def migrate
        m = File.join(@@task_root,'init.xml')
        `ant -f #{m}`
        p "migrate completed "
      end

      #按照ui.yml规则合并代码

      def merge
        backup = File.join(@@task_root,'merge.xml')
        m = File.join(@@task_root,'merge2.xml')

        xml = File.read(backup)
        str = '';
        @@targets.each do |v|
          p v['file']
          str += "<concat destfile=\"${dist.dir}/#{v['file']}\">"
          v["include"].each do |val|
            path = val.split('/')
            name = path.pop
            str += "<fileset dir=\"${dist.dir}/#{path.join('/')}\" includes=\"#{name}\" />"
          end
          str +="</concat>"
        end
        str =  xml.gsub('<!--concat-->',str)
        File.open(m, "w") do |out|
          out.write str
        end

        `ant -f #{m}`
        File.delete(m)

      end
      #压缩源码到#{RAILS_ROOT}/public/ui/min文件夹，产品发布时使用
      def build
        m = File.join(@@task_root,'min.xml')
        `ant -f #{m}`
      end



    end
    def initialize(file)
    end
  end
end
