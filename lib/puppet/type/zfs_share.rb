Puppet::Type.newtype(:zfs_share) do
  # zfs share documentation
  # https://docs.oracle.com/cd/E26502_01/html/E29031/zfs-share-1m.html
  #
  # Useful documentation about named shares
  # https://docs.oracle.com/cd/E26502_01/html/E29007/gayne.html#gentextid-6784
  @doc = "Manage zfs shares"

  require 'puppet/parameter/boolean'

  ensurable

  newparam(:name) do
    desc "Name of zfs file system"
    isnamevar
    validate do |value|
      if value =~ /^\//
        raise ArgumentError , "#{value} is not a valid zfs title"
      end
    end
  end

  newparam(:share_autoname) do
    desc "Replace the file system name with a specific name when creating an auto share."
    validate do |value|
      if value =~ /\s/
        raise ArgumentError , "#{value} is not a valid share name"
      end
    end
  end

  newproperty(:nfs) do
    desc "Enable or disable nfs"
    defaultto :on
    newvalues(:on, :off)
  end

  newproperty(:nfs_log) do
    desc "Enables NFSv2 or NFSv3 server logging for the specified file system. The tag is defined in the /etc/nfs/nfslog.conf file. If no tag is specified, the default values associated with the global tag in the /etc/nfs/nfslog.conf file is used."
  end

  newproperty(:nosub) do
    desc "Prevents NFSv2 or NFSv3 clients from mounting subdirectories of shared directories."
    newvalues(:on, :off)
  end

  newproperty(:sec_none_rw, :array_matching => :all) do
    validate do |value|
      unless value =~ /^\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}$|\*/
        raise ArgumentError , "#{value} is not a valid IP address."
      end
    end
    munge do |value|
      value.gsub(/^(?=\d)/, '@')
    end
  end

  newproperty(:sec_none_ro, :array_matching => :all) do
    validate do |value|
      unless value =~ /^\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}$|\*/
        raise ArgumentError , "#{value} is not a valid IP address."
      end
    end
    munge do |value|
      value.gsub(/^(?=\d)/, '@')
    end
  end

  newproperty(:sec_none_root) do
    desc "Sets the security mode to root access for access-list. By default, no system has root access."
  end

  newproperty(:sec_none_root_mapping) do
    desc "Sets the default security mode to root access to a specific UID. By default, no user has root access."
  end

  newproperty(:sec_sys_rw, :array_matching => :all) do
    validate do |value|
      unless value =~ /^\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}$|\*/
        raise ArgumentError , "%s is not a valid IP address."
      end
    end
    munge do |value|
      value.gsub(/^(?=\d)/, '@')
    end
  end

  newproperty(:sec_sys_ro, :array_matching => :all) do
    validate do |value|
      unless value =~ /^\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}$|\*/
        raise ArgumentError , "#{value} is not a valid IP address."
      end
    end
    munge do |value|
      value.gsub(/^(?=\d)/, '@')
    end
  end

  newproperty(:sec_sys_root)

  newproperty(:sec_sys_root_mapping)

  newproperty(:sec_default_rw, :array_matching => :all) do
    validate do |value|
      unless value =~ /^\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}$|\*/
        raise ArgumentError , "#{value} is not a valid IP address."
      end
    end
    munge do |value|
      value.gsub(/^(?=\d)/, '@')
    end
  end

  newproperty(:sec_default_ro, :array_matching => :all) do
    validate do |value|
      unless value =~ /^\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}$|\*/
        raise ArgumentError , "#{value} is not a valid IP address."
      end
    end
    munge do |value|
      value.gsub(/^(?=\d)/, '@')
    end
  end

  newproperty(:sec_default_root) do
    desc "Sets the default security mode to root access for access-list. By default, no system has root access."
  end

  newproperty(:sec_default_root_mapping) do
    desc "Sets the default security mode to root access to a specific UID. By default, no user has root access."
  end

  newproperty(:desc) do
    desc "Description of share."
  end

  newproperty(:nfs_aclok) do
    desc "Enables an NFS server that supports the NFS version 2 protocol to be configured to do access control for NFS version 2 clients."
  end

  newproperty(:anon) do
    desc "Sets UID to the effective user ID of unknown users. By default, unknown users are given the effective UID nobody. If UID is set to -1, access is denied. Value: uid"
    validate do |value|
      unless value =~ /\d{1,10}/
        raise ArgumentError , "#{value} is not a valid uid"
      end
    end
  end

  newproperty(:nfs_noaclfab) do
    desc "Allows NFS servers to not return fabricated ACLs to NFS clients."
    newvalues(:on, :off)
  end

  newproperty(:nfs_nosuid) do
    desc "Prevents the NFS client from creating files with setuid or setguid permissions. If enabled, the NFS server silently ignores any attempt to enable the setuid or setgid permissions."
    newvalues(:on, :off)
  end

  newproperty(:nfs_public) do
    desc "Changes the location of the public file handle from root to the shared directory for NFS-enabled browsers and clients."
    newvalues(:on, :off)
  end

  newproperty(:smb) do
    desc "Enable smb for a share."
    newvalues(:on, :off)
  end

  newproperty(:share_smb_abe) do
    desc "Enables Access-Based Enumeration (abe) support."
  end

  newproperty(:share_smb_csc) do
    desc "Enables client side caching support. The default value is disabled."
    newvalues(:disabled, :manual, :auto, :vdo)
  end

  newproperty(:share_smb_catia) do
    desc "Enables CATIA translation support."
  end

  newproperty(:share_smb_dfsroot) do
    desc "Enables DFS root support."
  end

  newproperty(:share_smb_guestok) do
    desc "Whether to allow guest access to smb shares"
    newvalues(:on, :off)
  end

  newproperty(:share_smb_ro) do
    desc "Sets the SMB share to read-only. You can specify on, off, or list of names."
  end

  newproperty(:share_smb_rw) do
    desc "Sets the SMB share to read-write. You can specify on, off, or list of names."
  end

  newproperty(:share_smb_none) do
    desc "Sets the SMB share to off for the specified users in the access-list."
  end

  newproperty(:share_path) do
    desc "Sets a mount-point relative path for a share."
  end

  newproperty(:share_auto) do
    desc "Editable property that disables automatic sharing and can only be set on the file system to be shared only."
    defaultto :on
    newvalues(:on, :off)
  end

  newproperty(:aclfab) do
    desc "Determines whether ACL permissions are fabricated."
    newvalues(:on, :off)
  end

  # Add share point to info from type
  #

end
