require 'puppet/property/boolean'

Puppet::Type.newtype(:maillist_config) do

  def initialize(*args)
    super

    # globaly munge some properties
    # 'available_languages' always has to include 'en' and the :preferred_language, sorted
    self[:available_languages] = \
      [ self[:available_languages], 'en', self[:preferred_language] ].flatten.compact.sort.uniq
    # sort members
    self[:members] = self[:members].sort unless self[:members].nil?
  end

  desc 'maillist_config configures a Mailman mailing lists'

  autorequire(:package) do
    ['mailman']
  end

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Name of the mailinglist'
    munge { |value| value.downcase }
  end

  newparam(:password) do
# MUSS Bei Anlegen!
  end

  newproperty(:real_name) do
    # can only differ by case from :name
    validate { |value|
      fail('\'real_name\' has to equal the lists \'name\', except for the case') \
        unless value.downcase == resource.name.downcase
    }
  end

  newproperty(:owner, :array_matching => :all) do
# MUSS Bei Anlegen!
    # 'simple' email regex
    newvalues(/^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/i)
    munge { |value| value.downcase }
  end

  newproperty(:moderator, :array_matching => :all) do
    # 'simple' email regex
    newvalues(/^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/i)
    munge { |value| value.downcase }
  end

  newproperty(:description) {}

  newproperty(:info) {}

  newproperty(:subject_prefix) {}

  newproperty(:send_welcome_msg, :boolean => true, :parent => Puppet::Property::Boolean) do
    def munge(value)
      super ? 1 : 0
    end
  end

  newproperty(:max_message_size) do
    munge { |value| Integer(value) }
  end

  newproperty(:preferred_language) {}

  newproperty(:available_languages, :array_matching => :all) {}

  newproperty(:accept_these_nonmembers, :array_matching => :all) {}

  newproperty(:generic_nonmember_action) do
# TODO validate 0..3?
    munge { |value| Integer(value) }
  end

  newproperty(:require_explicit_destination, :boolean => true, :parent => Puppet::Property::Boolean) do
    def munge(value)
      super ? 1 : 0
    end
  end

# TODO multiline match
  newproperty(:acceptable_aliases) {}

  newproperty(:max_num_recipients) do
    munge { |value| Integer(value) }
  end

  newproperty(:archive, :boolean => true, :parent => Puppet::Property::Boolean) do
    def munge(value)
      super ? 1 : 0
    end
  end

  newproperty(:members, :array_matching => :all) do
    # 'simple' email regex
    newvalues(/^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/i)
    munge { |value| value.downcase }
  end

end
