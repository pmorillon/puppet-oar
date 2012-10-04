Puppet::Type.type(:oar_property).provide(:oarproperty) do

  desc "Use oarproperty command"

  optional_commands :oarproperty => "oarproperty"

  def add
    options = resource[:varchar] ? "-c" : ""
    oarproperty("-a", resource[:name], options)
  end

  def remove
    oarproperty("-d", resource[:name])
  end

  def exists?
    oarproperty("-l").split("\n").include? resource[:name]
  end

end
