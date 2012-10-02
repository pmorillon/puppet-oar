Puppet::Type.type(:oar_admission_rule).provide(:mysql) do

  desc "Manage MySQL databases."

  optional_commands :mysql => "mysql"

  def self.rules
    rules = []

    regex = %r{^# Puppet name : (.+)((.|\s)+)}
    fields = [:name, :rule]

    mysql("-h", resource[:db_hostname], "-u", resource[:db_user], "-p#{resource[:db_password]}", "--database", resource[:db_name], "-NBe", "SELECT rule FROM admission_rules").split("\n").each do |line|
      if match = regex.match(line)
        hash = {}
        fields.zip(match.captures) do |field,value|
          hash[field] = value
        end
        rules << new(hash)
      end
    end

    rules
  end

  def add
    rule_text = "# Puppet name : #{resource[:name]}\n"
    rule_text += resource[:content]
    rule_text.gsub!(/\\|'/) { |x| "\\#{x}" }
    mysql("-h", resource[:db_hostname], "-u", resource[:db_user], "-p#{resource[:db_password]}", "--database", resource[:db_name], "-NBe", "INSERT INTO admission_rules (rule) VALUES ('#{rule_text}')")
  end

  def remove
    mysql("-h", resource[:db_hostname], "-u", resource[:db_user], "-p#{resource[:db_password]}", "--database", resource[:db_name], "-NBe", "DELETE FROM admission_rules WHERE rule REGEXP '^# Puppet name : #{resource[:name]}'")
  end

  def exists?
    mysql("-h", resource[:db_hostname], "-u", resource[:db_user], "-p#{resource[:db_password]}", "--database", resource[:db_name], "--raw", "-NBe", "SELECT rule FROM admission_rules").match(/^# Puppet name : #{resource[:name]}/)
  end

  def content
    regex = %r{^# Puppet name : (.+)\n([\s[:graph:]]+)}
    fields = [:name, :rule]
    result = mysql("-h", resource[:db_hostname], "-u", resource[:db_user], "-p#{resource[:db_password]}", "--database", resource[:db_name], "--raw", "-NBe", "SELECT rule FROM admission_rules WHERE rule REGEXP '^# Puppet name : #{resource[:name]}'")
    # Remove last carriage return added by --raw option of mysql command
    result.chomp!
    hash = {}
    if match = regex.match(result.to_s)
      fields.zip(match.captures) do |field,value|
        hash[field] = value
      end
    end
    hash[:rule]
  end

  def content=(rule)
    rule_text = "# Puppet name : #{resource[:name]}\n"
    rule_text += rule
    rule_text.gsub!(/\\|'/) { |x| "\\#{x}" }
    mysql("-h", resource[:db_hostname], "-u", resource[:db_user], "-p#{resource[:db_password]}", "--database", resource[:db_name], "-NBe", "UPDATE admission_rules SET rule='#{rule_text}' WHERE rule REGEXP '^# Puppet name : #{resource[:name]}'")
  end

end
