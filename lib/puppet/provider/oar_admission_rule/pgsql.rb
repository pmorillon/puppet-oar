Puppet::Type.type(:oar_admission_rule).provide(:pgsql) do

  desc "Manage PostgreSQL databases."

  has_command(:psql, "/usr/bin/psql") do
#    environment :PGPASSWORD => resource[:db_password]
  end

  def self.rules

  end

  def add
    rule_text = "# Puppet name : #{resource[:name]}\n"
    rule_text += resource[:content]
    rule_text.gsub!(/\\|'/) { |x| "\\#{x}" }
    Puppet::Util.withenv :PGPASSWORD => resource[:db_password] do
      psql("-h", resource[:db_hostname], "-U", resource[:db_user], "-d", resource[:db_name], "-c", "INSERT INTO admission_rules (rule) VALUES ('#{rule_text}')")
    end
  end

  def remove
    Puppet::Util.withenv :PGPASSWORD => resource[:db_password] do
      psql("-h", resource[:db_hostname], "-U", resource[:db_user], "-d", resource[:db_name], "-c", "DELETE FROM admission_rules WHERE rule LIKE '# Puppet name : #{resource[:name]}%'")
    end
  end

  def exists?
    result = Puppet::Util.withenv :PGPASSWORD => resource[:db_password] do
      psql("-h", resource[:db_hostname], "-U", resource[:db_user], "-d", resource[:db_name], "-t", "-A","-c", "SELECT rule FROM admission_rules").match(/# Puppet name : #{resource[:name]}/)
    end
    result
  end

  def content
    regex = %r{^# Puppet name : (.+)\n([\s[:graph:]]+)}
    fields = [:name, :rule]
    result = Puppet::Util.withenv :PGPASSWORD => resource[:db_password] do
      psql("-h", resource[:db_hostname], "-U", resource[:db_user], "-d", resource[:db_name], "-t", "-A", "-c", "SELECT rule FROM admission_rules WHERE rule LIKE '# Puppet name : #{resource[:name]}%'")
    end
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
    Puppet::Util.withenv :PGPASSWORD => resource[:db_password] do
      psql("-h", resource[:db_hostname], "-U", resource[:db_user], "-d", resource[:db_name], "-c", "UPDATE admission_rules SET rule='#{rule_text}' WHERE rule LIKE '# Puppet name : #{resource[:name]}%'")
    end
  end

end
