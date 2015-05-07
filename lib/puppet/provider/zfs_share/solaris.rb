require 'fileutils'

Puppet::Type.type(:zfs_share).provide(:solaris) do
  desc "ZFS share support for Solaris 11"

  commands :zfscmd => "zfs"
  share_title = resource[:zfs_name].gsub('/', '_')
  share_path = resource[:zfs_name].insert(0, "/")
  allow_ip = resource[:allow_ip].insert(0, '@')
  # REPLACE ME
  security = 'none'
  permission = 'rw'

  def exists?
    File.directory? resource[:zfs_name].insert(0, "/")
    #  "zfs get share #{title}"
    #end
  end

  def create
    zfscmd("set", "share=#{share_title},path=#{share_path},prot=nfs,sec=#{security},#{permission}=#{allow_ips}", resource[:zfs_name])
    #zfscmd "set share=#{share_title},path=#{share_path},prot=nfs,sec=#{security},#{permission}=#{allow_ips} #{title}"
  end

  def destroy
    zfscmd("set", "-c", "share=#{share_title},path=#{share_path}")
  end
end
