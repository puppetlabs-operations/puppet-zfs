Puppet::Type.type(:zfs_share).provide(:solaris) do
  desc "ZFS share support for Solaris 11"

  commands :zfscmd => "zfs"

  title = resource[:zfs_name]
  share_title = title.gsub('/', '_')
  share_path = title.insert 0, "/"

  allow_ip = resource[:allow_ip]
  allow_ips = allow_ip.insert 0, "@"

  # REPLACE ME
  security = 'none'
  permission = 'rw'

  command_base = [
    title_share,
    share_path
  ]

  def create
    system "zfs set share=#{share_title},path=#{share_path},prot=nfs,sec=#{security},#{permission}=#{allow_ips} #{title}"
  end

  def destroy
    system "zfs set -c share=#{share_title},path=#{share_path}"
  end

  def exists?
    "zfs get share #{title}"
  end
end
