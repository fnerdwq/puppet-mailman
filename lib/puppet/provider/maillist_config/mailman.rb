Puppet::Type.type(:maillist_config).provide :mailman do
  commands :newlist      => 'newlist',
           :rmlist       => '/var/lib/mailman/bin/rmlist',
           :list_lists   => '/var/lib/mailman/bin/list_lists',
           :config_list  => '/var/lib/mailman/bin/config_list',
           :sync_members => '/var/lib/mailman/bin/sync_members',
           :list_members => '/var/lib/mailman/bin/list_members'

  mk_resource_methods

  def self.instances
    lists = list_lists('--bare').split(/\n/)
    lists.collect do |list|
      cl = config_list('--outputfile','-', list)
      # filter encoding
      enc = cl[17..43].match(/-*- coding: (\S*) /).captures[0].upcase
      # force string to encoding
      cl_enc = cl.to_s.force_encoding(enc)
      config = Hash[
        cl_enc.split(/\n/)
          .reject{ |c| c =~ /^#|^$/ }
          .map{ |c| k, v = c.split(' = ');
                [k.to_sym, v ]
              }
      ]
      config.each do |k,v|
        config[k] = case v
        # Array
        when /^\[/
          # reset encoding
          # TODO Understand why....
          v.slice(1...-1).split(', ').map{ |e| e.slice(1...-1).force_encoding('UTF-8') }
        # String
 # TODO parse multiline string with """
        when /^'|"/
          # reset encoding
          # TODO Understand why....
          v.slice(1...-1).force_encoding('UTF-8')
        # Boolean (map to Interger)
        when /^(True|true)$/
          1
        when /^(False|false)$/
          0
        # Integer
        when /^\d*$/
          Integer(v)
        else
          # also for multiline parameters, which we ignore here
          nil
        end
      end
      config.delete_if{ |k,v| v.nil?}

      # get members
      members = list_members(list).split(/\n/).sort

      new({
          :name           => list,
          :ensure         => :present,
          :members        => members
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
    if    @resource[:owner].nil?    or @resource[:owner].empty? \
       or @resource[:password].nil? or  @resource[:password].empty?
      fail('Password an Owner must be given to create Mailinglist!')
    end

    newlist(@resource[:name], @resource[:owner][0], @resource[:password])
    @property_hash[:ensure] = :present

  self.class.resource_type.validproperties.each { |p|
      @property_hash[p] = @resource[p] \
        unless @resource[p].nil? or p == :ensure
    }
  end

  def destroy
# TODO purge? archives?
    rmlist(@resource[:name])
    @property_hash.clear
  end

  def flush
    # no flush if destroyed!
    return if @property_hash.empty?

    file = Tempfile.new(self.class.resource_type.name.to_s)
    file.write("# -*- python -*-\n# -*- coding: UTF-8 -*-\n")

    @property_hash.reject{ |k,v| [:name, :ensure, :members].include?(k) }.each do |k,v|
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
   
    # sync members to list
    file_mem = Tempfile.new(self.class.resource_type.name.to_s)
    file_mem.write(@property_hash[:members].join("\n"))
    file_mem.close

    sync_members('-f', file_mem.path, @resource[:name])
    file_mem.unlink
  end

  # special getter/setters
  def available_languages
    # compare sorted
    @property_hash[:available_languages].sort
  end

end

