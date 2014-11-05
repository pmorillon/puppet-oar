Puppet::Type.type(:oar_queue).provide(:oarnotify) do

  desc "Manage OAR queus with oarnotify command"

  optional_commands :oarnotify => "oarnotify"

  $oarnotify_options = {}

  def checkOARVersion
    $oar_version ||= File.read('/usr/share/perl5/OAR/Version.pm').scan(/\d+\.\d+\.\d+/).first
    $oarnotify_options[:add] = Gem::Version.new($oar_version) > Gem::Version.new('2.5.3') ? '--add-queue' : '--add_queue'
    $oarnotify_options[:remove] = Gem::Version.new($oar_version) > Gem::Version.new('2.5.3') ? '--remove-queue' : '--remove_queue'
  end

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
    checkOARVersion
    oarnotify($oarnotify_options[:add], "#{resource[:name]},#{resource[:priority]},#{resource[:scheduler]}")
    state = queues.select { |queue| queue[:name] == resource[:name] }.first[:state]
    if resource[:enabled] == :false
      oarnotify("-d", resource[:name])
    end
  end

  def remove
    checkOARVersion
    oarnotify($oarnotify_options[:remove], resource[:name])
  end

  def exists?
    not queues.select { |queue| queue[:name] == resource[:name] }.empty?
  end

  def priority
    queues.select { |queue| queue[:name] == resource[:name] }.first[:priority]
  end

  def priority=(value)
    checkOARVersion
    oarnotify($oarnotify_options[:remove], resource[:name])
    oarnotify($oarnotify_options[:add], "#{resource[:name]},#{resource[:priority]},#{resource[:scheduler]}")
  end

  def scheduler
    queues.select { |queue| queue[:name] == resource[:name] }.first[:scheduler]
  end

  def scheduler=(value)
    checkOARVersion
    oarnotify($oarnotify_options[:remove], resource[:name])
    oarnotify($oarnotify_options[:add], "#{resource[:name]},#{resource[:priority]},#{resource[:scheduler]}")
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
