module PuppetX
  module Puppetlabs
    class Zfsshare < Puppet::Provider

      def self.get_shares
        shares = {}
        a = IO.popen(['zfs', 'get', '-e', '-s', 'local,inherited', 'share.all'])
        a.each do |l|
          s = l.split()
          shares[s[0]] = {} unless shares[s[0]]
          # When a property is set the array length will be 4
          if s.length == 4
            if not s[2] == '...'
              # Return multiple IP addresses as an array to allow comparison to work
              if s[2] =~ /^@?\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}:@?/
                shares[s[0]][s[1]] = s[2].split(':')
              # Return a single address as an array
              elsif s[2] =~ /^@?\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\/\d{1,2}$/
                shares[s[0]][s[1]] = [s[2]]
              elsif s[2] == '*'
                shares[s[0]][s[1]] = [s[2]]
              else
                shares[s[0]][s[1]] = s[2]
              end
            end
          end
        end
        a.close
        return shares
      end

      def self.list_shares
        shares = get_shares()
        for k,v in shares
          if k =~ /%/
            s = k.split('%')
            shares[s[0]]['named_share'] = s[1] unless s.length < 2
            shares.delete(k)
          end
        end
        return shares
      end
    end
  end
end
