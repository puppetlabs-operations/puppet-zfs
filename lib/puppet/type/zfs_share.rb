Puppet::Type.newtype(:zfs_share) do
  @doc = "Manage zfs shares"

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc "Name of zfs file system"

    validate do |value|
      unless value =~ /(?!\/|\d)^\w.*/
        raise ArgumentError , "%s is not a valid zfs path."
      end
    end
  end

  newparam(:allow_ip) do
    desc "IP allowed to access share"

    validate do |value|
      unless value =~ /^\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{2}/
        raise ArgumentError , "%s is not a valid IP for setting a zfs share."
      end
    end
  end

# autorequire(:zfs) do
#   self[:name]
# end
end