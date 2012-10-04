#This is a type to manage OAR adminssion rules

Puppet::Type.newtype(:oar_admission_rule) do
  @doc = "Manage OAR adminssion rules"

  ensurable do
    newvalue(:present, :event => :rule_installed) do
      provider.add
    end

    newvalue(:absent, :event => :rule_removed) do
      provider.remove
    end

    defaultto :present
  end

  newparam(:name) do
    desc "The uniq name of the admission rule."
    isnamevar
  end

  newproperty(:content) do
    desc "The rule content in Perl."

  end

  newparam(:db_hostname) do
    desc "OAR database hostname."

  end

  newparam(:db_user) do
    desc "OAR database username with privileges."

  end

  newparam(:db_password) do
    desc "OAR database password."

  end

  newparam(:db_name) do

  end

  # def exists?
  #   !@provider.instances.select { |rule| rule[:name] == self[:name] }.empty?
  # end

end
