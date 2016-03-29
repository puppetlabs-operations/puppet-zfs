require 'puppet_x/puppetlabs/zfsshare'

Puppet::Type.type(:zfs_share).provide(:solaris, :parent => PuppetX::Puppetlabs::Zfsshare) do
  desc "ZFS share support for Solaris 11"

  confine :operatingsystem => :solaris
  confine :operatingsystemrelease => [ 11.2, 11.3 ]

  commands :zfs => 'zfs'

  mk_resource_methods

  def self.instances
    begin
      list_shares.collect do |k, v|
        name = k
        nfs = v['share.nfs']
        anon = v['share.nfs.anon']
        nosub = v['share.nfs.nosub']
        security = v['share.nfs.sec']
        sec_sys_rw = v['share.nfs.sec.sys.rw']
        sec_default_ro = v['share.nfs.sec.default.ro']
        sec_default_rw = v['share.nfs.sec.default.rw']
        sec_default_root = v['share.nfs.sec.default.root']
        sec_default_root_mapping = v['share.nfs.sec.default.root_mapping']
        sec_none_ro = v['share.nfs.sec.none.ro']
        sec_none_rw = v['share.nfs.sec.none.rw']
        sec_none_root = v['share.nfs.sec.none.root']
        sec_none_root_mapping = v['share.nfs.sec.none.root_mapping']
        sec_sys_ro = v['share.nfs.sec.sys.ro']
        sec_sys_rw = v['share.nfs.sec.sys.rw']
        sec_sys_root = v['share.nfs.sec.sys.root']
        sec_sys_root_mapping = v['share.nfs.sec.sys.root_mapping']
        desc = v['share.desc']
        share_autoname = v['share.autoname']
        nfs_aclok = v['share.nfs.aclok']
        nfs_noaclfab = v['share.nfs.noaclfab']
        nfs_nosuid = v['share.nfs.nosuid']
        nfs_public = v['share.nfs.public']
        share_auto = v['share.auto']
        smb = v['share.smb']
        share_smb_abe = v['share.smb.abe']
        share_smb_catia = v['share.smb.catia']
        share_smb_dfsroot = v['share.smb.dfsroot']
        share_smb_guestok = v['share.smb.guestok']
        share_smb_ro = v['share.smb.ro']
        share_smb_rw = v['share.smb.rw']
        new( :name => name,
               :ensure => :present,
               :path => name,
               :nfs => nfs,
               :anon => anon,
               :nosub => nosub,
               :security => security,
               :sec_default_ro => sec_default_ro,
               :sec_default_rw => sec_default_rw,
               :sec_default_root => sec_default_root,
               :sec_default_root_mapping => sec_default_root_mapping,
               :sec_none_ro => sec_none_ro,
               :sec_none_rw => sec_none_rw,
               :sec_none_root => sec_none_root,
               :sec_none_root_mapping => sec_none_root_mapping,
               :sec_sys_ro => sec_sys_ro,
               :sec_sys_rw => sec_sys_rw,
               :sec_sys_root => sec_sys_root,
               :sec_sys_root_mapping => sec_sys_root_mapping,
               :desc => desc,
               :share_autoname => share_autoname,
               :nfs_aclok => nfs_aclok,
               :nfs_noaclfab => nfs_noaclfab,
               :nfs_nosub => nosub,
               :nfs_nosuid => nfs_nosuid,
               :nfs_public => nfs_public,
               :share_auto => share_auto,
               :smb => smb,
               :share_smb_abe => share_smb_abe,
               :share_smb_catia => share_smb_catia,
               :share_smb_dfsroot => share_smb_dfsroot,
               :share_smb_guestok => share_smb_guestok,
               :share_smb_ro => share_smb_ro,
               :share_smb_rw => share_smb_rw,
           )
      end
    rescue StandardError
      raise
    end
  end

  def self.prefetch(resources)
    shares = instances
    resources.keys.each do |name|
      if provider = shares.find{ |share| share.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    zfs(:set, 'share.nfs=on', @resource[:name])
    @property_hash[:ensure] = :present
  end

  def destroy
    zfs(:set, 'share.nfs=off', @resource[:name])
    @property_hash.clear
  end

  def desc=(value)
    zfs(:set, "share.desc=#{value}", @resource[:name])
    @property_hash[:desc] = value
  end

  [:nfs, :smb].each do |field|
    f = field.to_s
    define_method(f + '=') do |value|
      begin
        zfs(:set, "share.#{f}=#{value}", @resource[:name])
        @property_hash[field] = value
      rescue
      end
    end
  end

  [:sec_none_rw, :sec_none_ro, :sec_default_rw, :sec_default_ro,
   :sec_sys_rw, :sec_sys_ro].each do |field|
    f = field.to_s
    define_method(f + '=') do |value|
      begin
        value = value.join(':')
        zfs(:set, "share.nfs.#{f.gsub('_', '.')}=#{value}", @resource[:name])
        @property_hash[field] = value
      rescue
      end
    end
  end

  [:share_smb_rw, :share_smb_ro].each do |field|
    f = field.to_s
    define_method(f + '=') do |value|
      begin
        value = value.join(':')
        zfs(:set, "#{f.gsub('_', '.')}=#{value}", @resource[:name])
        @property_hash[field] = value
      rescue
      end
    end
  end

  [:share_smb_abe, :share_smb_catia, :share_smb_dfsroot, :share_smb_guestok,
   :share_auto, :share_autoname].each do |field|
    f = field.to_s
    define_method(f + '=') do |value|
      begin
        zfs(:set, "#{f.gsub('_', '.')}=#{value}", @resource[:name])
        @property_hash[field] = value
      rescue
      end
    end
  end

  [:anon, :nosub, :sec_none_root, :sec_default_root,
   :sec_sys_root, :nfs_aclok, :nfs_noaclfab, :nfs_nosuid,
   :nfs_public].each do |field|
    f = field.to_s
    define_method(f + '=') do |value|
      begin
        zfs(:set, "share.nfs.#{f.gsub('_', '.')}=#{value}", @resource[:name])
        @property_hash[field] = value
      rescue
      end
    end
  end

 [:sec_none_root_mapping, :sec_default_root_mapping, :sec_sys_root_mapping].each do |field|
   f = field.to_s
   define_method(f + '=') do |value|
     begin
       mapping = f.gsub('_', '.').sub('.map', '_map')
       zfs(:set, "share.nfs.#{mapping}=#{value}", @resource[:name])
       @property_hash[field] = value
     rescue
     end
   end
 end
end
