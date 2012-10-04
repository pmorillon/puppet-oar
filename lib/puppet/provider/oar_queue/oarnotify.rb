Puppet::Type.type(:oar_queue).provide(:oarnotify) do

  desc "Manage OAR queus with oarnotify command"

  optional_commands :oarnotify => "oarnotify"

  def queues

    oar_queues = []
    queue = {}

    oarnotify("-l").split("\n").each do |line|
      if line.match(/^(\w+)$/)
        queue[:name] = line
      end
      if m = line.match(/^\t(\w+) = (.*)$/)
        queue[m[1].to_sym] = m[2]
        if m[1] == "state"
          oar_queues << queue
          queue = {}
        end
      end
    end
    oar_queues
  end

  def add
    oarnotify("--add_queue", "#{resource[:name]},#{resource[:priority]},#{resource[:scheduler]}")
  end

  def remove

  end

  def exists?
    not queues.select { |queue| queue[:name] == resource[:name] }.empty?
  end

  def priority
    queues.select { |queue| queue[:name] == resource[:name] }.first[:priority]
  end

  def priority=(value)
    oarnotify("--remove_queue", resource[:name])
    oarnotify("--add_queue", "#{resource[:name]},#{resource[:priority]},#{resource[:scheduler]}")
  end

  def scheduler
    queues.select { |queue| queue[:name] == resource[:name] }.first[:scheduler]
  end

  def scheduler=(value)
    oarnotify("--remove_queue", resource[:name])
    oarnotify("--add_queue", "#{resource[:name]},#{resource[:priority]},#{resource[:scheduler]}")
  end

  def enabled
    state = queues.select { |queue| queue[:name] == resource[:name] }.first[:state]
    state == "Active" ? :true : :false
  end

  def enabled=(value)
    option = ""
    case resource[:enabled]
    when :true
      option = "-e"
    when :false
      option = "-d"
    end
    oarnotify(option, resource[:name])
  end

end
