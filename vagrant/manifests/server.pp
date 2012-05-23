# OAR server installation with puppet and vagrant

$oar_version = "2.5"
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
    source  => "${files_path}/oar.conf",
    require => Package["oar-server"],
    notify  => Service["oar-server"];
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

} # Class:: vagrant::oar::mysql

