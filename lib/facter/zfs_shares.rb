Facter.add("zfs_shares") do

  confine :operatingsystem => 'Solaris'
  setcode do
    Facter::Core::Execution.exec('zfs get share')
  end
end
