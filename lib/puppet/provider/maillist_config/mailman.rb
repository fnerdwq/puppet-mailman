Puppet::Type.type(:maillist_config).provide :mailman do
  commands :newlist     => 'newlist',
           :rmlist      => '/var/lib/mailman/bin/rmlist',
           :list_lists  => '/var/lib/mailman/bin/list_lists',
           :config_list => '/var/lib/mailman/bin/config_list'

  mk_resource_methods

  def self.instances 
    lists = list_lists('--bare').split(/\n/)
    lists.collect do |list|
      cl = config_list('--outputfile','-', list)
# TODO aufraumen
      enc = cl[17..43].match(/-*- coding: (\S*) /).captures[0].upcase
 p enc
      clOK =  cl.to_s.force_encoding(enc).encode("UTF-8")

      config = Hash[
        clOK.split(/\n/)
          .reject{ |c| c =~ /^#|^$/ }
          .map{ |c| k, v = c.split(' = '); 
                    [k.to_sym, v] 
              }
      ]
      config.each do |k,v|
        config[k] = case v
        when /^\[/
          v.slice(1...-1).split(', ').map{ |e| e.slice(1...-1) }
        when /^'/
          v.slice(1...-1) 
 # TODO parse multiline string with """
        when /^(True|true)$/
          0
        when /^(False|false)$/
          1
        when /^\d*$/
          Integer(v)
        else
          # also for multiline parameters, which we ignore here
          nil 
        end
      end
      config.delete_if{ |k,v| v.nil?}

      new({ 
          :name           => list,
          :ensure         => :present,
         }.merge(config)
      )
    end
  end

  def self.prefetch(lists)
### TODO load only relevant instance
    instances.each do |prov|
      if list = lists[prov.name]
        list.provider = prov
      end
    end
  end

  def exists?
    @property_hash[:ensure] || false
  end

  def create
    if    @resource[:owner].nil? or @resource[:owner].empty? \
       or @resource[:password].nil? or  @resource[:password].empty?
      fail('Password an Owner must be given to create Mailinglist!')
    end

    newlist(@resource[:name], @resource[:owner][0], @resource[:password])
    @property_hash[:ensure] = :present

# TODO can I access the type or the types name directly?
    Puppet::Type.type(:maillist_config).properties.each { |p| 
      @property_hash[p.name] = @resource[p.name] \
        unless @resource[p.name].nil? or p.name == :ensure
    }
  end

  def destroy
# purge? archives?
    rmlist(@resource[:name])
    @property_hash.clear
  end

  def flush
    # no flush if destroyed!
    return if @property_hash.empty?

    file = File.new('/tmp/asdf','w')
#Tempfile.new('maillist_config')
    file.write("# -*- python -*-
                # -*- coding: UTF-8 -*-\N")

    @property_hash.reject{ |k,v| [:name, :ensure].include?(k) }.each do |k,v|
      outval = case v
      when Array 
        v
      when String 
# TODO encoding
        if v.include?("\n")
# TODO indentation of newlines
          "\"\"\"#{v}\"\"\""
        else
          "'#{v}'"
        end
      when Integer
        v.to_s
      else 
        fail("Wrong value in @property_hash[#{k}] = #{v}")
      end
      file.write("#{k} = #{outval}\n")
    end
    file.close

    config_list('--inputfile', file.path, @resource[:name])
    file.unlink
  end

end

