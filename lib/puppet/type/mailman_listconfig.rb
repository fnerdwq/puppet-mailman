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
  
  newproperty(:send_welcome_msg, :boolean => true) do
    newvalues(:true, :false)
  end

  newproperty(:max_message_size) do
    munge do |value|
      Integer(value)
    end
  end

  newproperty(:accept_these_nonmembers, :array_matching => :all) do
  end

  newproperty(:require_explicit_destination, :boolean => true) do
    newvalues(:true, :false)
  end

  newproperty(:archive, :boolean => true) do
    newvalues(:true, :false)
  end

end
