Puppet::Type.newtype(:oar_property) do
  @doc = "Manage OAR properties"

  ensurable do
    newvalue(:present) do
      provider.add
    end

    newvalue(:absent) do
      provider.remove
    end

    defaultto :present
  end

  newparam(:name) do
    desc "The uniq name of the OAR property"
    isnamevar
  end

  newparam(:varchar) do
    desc "SQL field of type VARCHAR(255)"
  end

end
