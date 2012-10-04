Puppet::Type.newtype(:oar_queue) do
  @doc = "Manage OAR queues"

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
    desc "The uniq name of the OAR queue"
    isnamevar
  end

  newproperty(:priority) do
    desc "Queue priority"
  end

  newproperty(:scheduler) do
    desc "Queue scheduler"
  end

  newproperty(:enabled) do
    desc "Enable or not the queue"
    newvalues(:true, :false)
  end

end
