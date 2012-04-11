Facter.add("haszfs") do

  # By default Solaris doesn't include the filesystem.
  if Facter.value('operatingsystem') == 'Solaris'
    mountcmd='mount -v'
  else
    mountcmd='mount'
  end

  setcode do
    if `#{mountcmd}` !~ /zfs/
      false
    else
      true
    end
  end
end
