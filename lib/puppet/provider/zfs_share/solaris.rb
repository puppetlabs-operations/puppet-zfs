Puppet::Type.type(:zfs_share).provide(:solaris) do
  desc "ZFS share support for Solaris 11"

  commands :zfscmd => "zfs"
  share_title = String.try_convert(@resource[:zfs_name].gsub('/', '_'))
  share_path = String.try_convert(@resource[:zfs_name].insert(0, "/"))
  allow_ip = String.try_convert(@resource[:allow_ip].insert(0, '@'))
  # REPLACE ME
  security = 'none'
  permission = 'rw'

  def exists?
    begin
      zfscmd("list", @resource[:zfs_name])
      true
    rescue Puppet::ExecutionFailure
      false
    end
    #  "zfs get share #{title}"
    #end
  end

  def create
    zfscmd("set", "share=#{share_title},path=#{share_path},prot=nfs,sec=#{security},#{permission}=#{allow_ips}", @resource[:zfs_name])
    #zfscmd "set share=#{share_title},path=#{share_path},prot=nfs,sec=#{security},#{permission}=#{allow_ips} #{title}"
  end

  def destroy
    zfscmd("set", "-c", "share=#{share_title},path=#{share_path}")
  end
end
