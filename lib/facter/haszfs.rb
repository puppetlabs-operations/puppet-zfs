Facter.add("haszfs") do
  setcode do
    case Facter.value('operatingsystem')
    when "windows"
      false
    when "Solaris"
      # By default Solaris doesn't include the filesystem.
      `mount -v` =~ /zfs/ ? true : false
    else
      `mount` =~ /zfs/ ? true : false
    end
  end
end
