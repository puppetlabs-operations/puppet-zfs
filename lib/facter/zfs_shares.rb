Facter.add("zfs_shares") do

  confine :operatingsystemrelease => '5.11' if Facter.value(:osfamily) == 'Solaris'
  setcode do
    shares = `zfs get share`
    if shares
      shares
    end
  end
end
