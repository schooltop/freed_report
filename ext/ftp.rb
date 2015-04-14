module Net
  class FTP
    def mput(pattern, &block)
      Dir[pattern].each{ |file| put(file, &block) }
    end

    def mget(pattern, remote_path = ".", local_path = ".", &block)
#      remote_path = is_cw ? remote_path + "/" + pattern : remote_path  # 重庆现场
      files = remote_path.blank? ? list(pattern) : list(remote_path + "/" + pattern)
#      files = is_cw ? list(remote_path) : nlst(remote_path)   # 重庆现场
      localfiles = []
      files.each{ |file|
        filename = filename(file)
        file_extname = filename.split(".").last
        localfile = local_path + "/" + File.basename(filename)
        ext_name = ["txt","xml", "dat"] # 标准的文本文件结尾
        ext_name << "end" # 重庆现场备份文件采集.end 结尾，实际上是TXT文件
        if(ext_name.include?(file_extname.downcase)||file_extname.downcase.match(/\d{4}-\d{1,2}-\d{1,2}$/))
          gettextfile(remote_path + "/" + filename, localfile, &block)
#          gettextfile( filename, localfile, &block)   # 重庆现场
        else
          getbinaryfile(remote_path + filename, localfile, &block)
        end
        sleep(1)
        localfiles << localfile
      }
      return localfiles
    end

    def filename(o_filename)
      if(o_filename.start_with?("l"))
        s = o_filename.split(" ")
        s[s.length - 3]
      else
        o_filename.split(" ").last
      end
    end
  end
end
