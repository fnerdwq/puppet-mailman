Puppet::Type.type(:mailman_listconfig).provide :mailman do
  commands :newlist     => 'newlist',
           :rmlist      => '/var/lib/mailman/bin/rmlist',
           :list_lists  => '/var/lib/mailman/bin/list_lists',
           :config_list => '/var/lib/mailman/bin/config_list'

  mk_resource_methods

  def self.instances 
    lists = list_lists('--bare').split(/\n/)
    lists.collect do |list|
      config = Hash[
        config_list('--outputfile','-', list)
          .split(/\n/)
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
 # TODO Multiline string """
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
#### sinnvoll fuer alle?
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

# setzen alle parameter?
    properties = [:real_name,
                  :owner,
                  :moderator,
                  :description,
                  :info,
                  :subject_prefix, 
                  :send_welcome_msg,
                  :accept_these_nonmembers,
                  :require_explicit_destination,
                  :archive
    ]
    properties.each { |p|
      @property_hash[p] = @resource[p] unless @resource[p].nil?
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

    file = Tempfile.new('mailman_listconfig')

    @property_hash.reject{ |k,v| [:name, :ensure].include?(k) }.each do |k,v|
      outval = case v
      when Array 
        v
      when String 
        if v.include?("\n")
# TODO indentation!!!
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

