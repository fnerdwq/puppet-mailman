require 'puppet/property/boolean'

Puppet::Type.newtype(:mailman_listconfig) do

  desc 'mailman_listconfig configures a Mailman mailing lists'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Name of the mailinglist'
  end

  newparam(:password) do
# MUSS Bei Anlegen!
  end

  newproperty(:real_name) do
# bis aus Schreibung wie name!!!!
  end

  newproperty(:owner, :array_matching => :all) do
# MUSS Bei Anlegen!
  end

  newproperty(:moderator, :array_matching => :all) do
  end

  newproperty(:description) do
  end

  newproperty(:info) do
  end

  newproperty(:subject_prefix) do
  end
  
  newproperty(:send_welcome_msg, :boolean => true, :parent => Puppet::Property::Boolean) do
    def munge(value)
      super ? 1 : 0
    end
  end

  newproperty(:max_message_size) do
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:accept_these_nonmembers, :array_matching => :all) do
  end

  newproperty(:require_explicit_destination, :boolean => true, :parent => Puppet::Property::Boolean) do
    def munge(value)
      super ? 1 : 0
    end
  end

  newproperty(:archive, :boolean => true, :parent => Puppet::Property::Boolean) do
    def munge(value)
      super ? 1 : 0
    end
  end

end
