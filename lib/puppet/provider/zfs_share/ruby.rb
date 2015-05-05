require 'fileutils'

Puppet::Type.type(:zfs_share).provide(:ruby) do
  desc "ZFS share support for Solaris 11"

  commands :zfscmd => "zfs"
  share_title = @resource[:name].gsub('/', '_')
  share_path = @resource[:name].(insert 0, "/")
  allow_ip = @resource[:allow_ip].insert(0, '@')
  # REPLACE ME
  security = 'none'
  permission = 'rw'

  def exists?
    File.directory? @share_path
    #  "zfs get share #{title}"
    #end
  end

  def create
    zfscmd "set", "share=#{share_title},path=#{share_path},prot=nfs,sec=#{security},#{permission}=#{allow_ips}", resource[:name]
    #zfscmd "set share=#{share_title},path=#{share_path},prot=nfs,sec=#{security},#{permission}=#{allow_ips} #{title}"
  end

  def destroy
    zfscmd "set", "-c", "share=#{share_title},path=#{share_path}"
  end
end
