# OAR server installation with puppet and vagrant

$oar_version = "2.5"
$oar_home    = "/var/lib/oar"
$files_path  = "/tmp/vagrant-puppet/manifests/files"

class {
  "oar::server":
    version => $oar_version,
    db      => "mysql";
  "oar::frontend":
    version =>  $oar_version,
}

include "vagrant::oar::mysql"

file {
  "/etc/oar/oar.conf":
    ensure  => file,
    mode    => 600, owner => oar, group => root,
    source  => "${files_path}/conf/server/oar.conf",
    require => Package["oar-server"],
    notify  => Service["oar-server"];
  "/etc/hosts":
    ensure  => file,
    mode    => 644, owner => root, group => root,
    source  => "${files_path}/conf/server/hosts",
    require => Package["oar-server"];
  "${oar_home}/.ssh/authorized_keys":
    ensure  => file,
    mode    => 644, owner => oar, group => oar,
    source  => "${files_path}/keys/server/authorized_keys",
    require => Package["oar-server"];
  "${oar_home}/.ssh/id_rsa":
    ensure  => file,
    mode    => 600, owner => oar, group => oar,
    source  => "${files_path}/keys/server/id_rsa",
    require => Package["oar-server"];
  "${oar_home}/.ssh/id_rsa.pub":
    ensure  => file,
    mode    => 644, owner => oar, group => oar,
    source  => "${files_path}/keys/server/id_rsa.pub",
    require => Package["oar-server"];
  "/etc/hostname":
    ensure  => file,
    mode    => 644, owner => root, group => root,
    content => "oar-server
",
    require => Exec["Mysql: add OAR default datas"],
    notify  => Exec["/etc/init.d/hostname.sh"];
}

exec {
  "/etc/init.d/hostname.sh":
    refreshonly => true,
    notify      => [Service["oar-server"], Exec["/etc/init.d/oar-node restart"]];
  "/etc/init.d/oar-node restart":
    refreshonly => true;
}

service {
  "oar-node":
    enable => true,
    require => Package["oar-node"];
}

# Class:: vagrant::oar::mysql
#
#
class vagrant::oar::mysql {

  $db_name = "oar2"

  package {
    "mysql-server":
      ensure  => installed;
  }

  service {
    "mysql":
      ensure  => running,
      enable  => true,
      require => Package["mysql-server"];
  }

  exec {
    "Mysql: create ${db_name} db":
      command => "/usr/bin/mysql --execute=\"CREATE DATABASE ${db_name};\"",
      unless  => "/usr/bin/mysql --execute=\"SHOW DATABASES;\" | grep '^${db_name}$'",
      require => Service["mysql"];
    "Mysql: init oar privileges":
      command => "/usr/bin/mysql --execute=\"GRANT ALL PRIVILEGES ON ${db_name}.* TO \'oar\'@\'%\' IDENTIFIED BY \'vagrant\';\"",
      unless  => "/usr/bin/mysql --execute=\"SHOW GRANTS FOR oar@\'%\';\"",
      require => Exec["Mysql: create ${db_name} db"];
    "Mysql: init oar_ro privileges":
      command => "/usr/bin/mysql --execute=\"GRANT SELECT ON ${db_name}.* TO \'oar_ro\'@\'%\' IDENTIFIED BY \'vagrant\';\"",
      unless  => "/usr/bin/mysql --execute=\"SHOW GRANTS FOR oar_ro@\'%\';\"",
      require => Exec["Mysql: create ${db_name} db"];
    "Mysql: init OAR database":
      command => "/usr/bin/mysql oar2 < /usr/lib/oar/database/mysql_structure.sql",
      unless  => "/usr/bin/mysql -u root --execute=\"SHOW TABLES;\" oar2 | grep jobs",
      require => [Exec["Mysql: create ${db_name} db"],Package["oar-server"]],
      notify  => Exec["Mysql: add OAR default datas", "Mysql: add OAR default admission rules"];
    "Mysql: add OAR default datas":
      command     => "/usr/bin/mysql oar2 < /usr/lib/oar/database/default_data.sql",
      refreshonly => true,
      require     => Exec["Mysql: init OAR database"],
      notify      => Service["oar-server"];
    "Mysql: add OAR default admission rules":
      command     => "/usr/bin/mysql oar2 < /usr/lib/oar/database/mysql_default_admission_rules.sql",
      refreshonly => true,
      require     => Exec["Mysql: init OAR database"];
  }

  # Allow connection from all
  file {
    "/etc/mysql/conf.d/vagrant.cnf":
      ensure  => file,
      mode    => 644, owner => root, group => root,
      content => "[mysqld]
bind-address = 0.0.0.0
",
      notify  => Service["mysql"],
      require => Package["mysql-server"];
  }


} # Class:: vagrant::oar::mysql

