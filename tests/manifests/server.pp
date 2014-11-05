# OAR server installation with Vagrant and Puppet

include "vagrant::oar::${oar_db}"
include "vagrant::oar::api"

$db = 'pgsql'

$files_path  = "/vagrant/manifests/files"

if $oar_db {
  case $oar_db {
    mysql,pgsql: {
      notice("Using ${oar_db} backend.")
    }
    default: {
      error("${oar_db} databases are not supported.")
    }
  }
} else {
  $oar_db = "mysql"
  notice("Using default ${oar_db} backend")
}

class {
  'oar':
    version => 'latest',
    db      => $oar_db,
    suite   => 'stable';
}

class {
  'oar::server':
}

class {
  'oar::user':
}

class {
  'oar::api':
}

package {
  'taktuk':
    ensure => installed;
}

file {
  "/etc/oar/oar.conf":
    ensure  => file,
    mode    => 600, owner => oar, group => root,
    source  => "${files_path}/conf/server/oar.conf_${oar_db}",
    require => Package["oar-server"],
    notify  => Service["oar-server"];
  "/etc/hosts":
    ensure  => file,
    mode    => 644, owner => root, group => root,
    source  => "${files_path}/conf/server/hosts",
    require => Package["oar-server"];
  "${oar::home_path}/.ssh/authorized_keys":
    ensure  => file,
    mode    => 644, owner => oar, group => oar,
    source  => "${files_path}/keys/server/authorized_keys",
    require => Package["oar-server"];
  "${oar::home_path}/.ssh/id_rsa":
    ensure  => file,
    mode    => 600, owner => oar, group => oar,
    source  => "${files_path}/keys/server/id_rsa",
    require => Package["oar-server"];
  "${oar::home_path}/.ssh/id_rsa.pub":
    ensure  => file,
    mode    => 644, owner => oar, group => oar,
    source  => "${files_path}/keys/server/id_rsa.pub",
    require => Package["oar-server"];
  "/etc/hostname":
    ensure  => file,
    mode    => 644, owner => root, group => root,
    content => "oar-server",
    #    require => Exec["${oar_db}: add OAR default datas"],
    notify  => Exec["/etc/init.d/hostname.sh"];
  "/etc/oar/apache2/oar-restful-api.conf":
    ensure  => file,
    mode    => 600, owner => www-data, group => root,
    source  => "${files_path}/conf/server/oar-restful-api.conf",
    require => Package["oar-api"],
    notify  => Service["apache2"];
  '/etc/default/locale':
    ensure  => file,
    mode    => '644',
    owner   => root,
    group   => root,
    content => 'LANG="en_US.UTF-8"
LC_ALL="en_US.UTF-8"';
}

exec {
  "/etc/init.d/hostname.sh":
    refreshonly => true,
    notify      => Service["oar-server"];
}

if ($operatingsystem == "Ubuntu") {
  Exec["/etc/init.d/hostname.sh"] { command => "/etc/init.d/hostname restart" }
}

# Create OAR properties

Oar_property {
  require => Class["vagrant::oar::${oar_db}"]
}

oar_property {
  ["cpu", "core"]:
    ensure  => present;
  "ip":
    ensure  => present,
    varchar => true;
}

# Create OAR queues

Oar_queue {
  require => Class["vagrant::oar::${oar_db}"]
}

oar_queue {
  "testing":
    ensure    => present,
    priority  => 1,
    scheduler => "oar_sched_gantt_with_timesharing",
    enabled   => false;
}

Oar_admission_rule {
  db_name     => 'oar2',
  db_hostname => 'localhost',
  db_user     => 'oar',
  db_password => 'vagrant',
  provider    => $oar_db
}

oar_admission_rule {
  'Maintenance in progress':
    ensure  => present,
    content => '#blablabla';
}

Package['oar-api'] -> Service['apache2']

package {
  ['oidentd', 'curl']:
  ensure  => installed;
}

service {
  'ssh':
    ensure  => running,
    enable  => true;
}

augeas {
  'sshd_config_PermitUserEnvironment':
    context   => 'files/etc/ssh/sshd_config',
    changes   => 'set /files/etc/ssh/sshd_config/PermitUserEnvironment yes',
    notify    => Service['ssh'];
}


# Class:: vagrant::oar::mysql
#
#
#class vagrant::oar::mysql {

  #$db_name = "oar2"

  #class { 'mysql::server':
    #config_hash => { 'root_password' => '' , 'bind_address' => '0.0.0.0' }
  #}

  #mysql::db {
    #$db_name:
      #user      => 'oar',
      #password  => 'vagrant',
      #host      => '%',
      #charset   => 'latin1',
      #grant     => ['all'];
  #}

  #database_user {
    #'oar_ro@%':
      #password_hash => mysql_password('vagrant');
  #}

  #database_grant {
    #'oar_ro@%/oar2':
      #privileges => ['Select_priv'];
  #}

  #exec {
    #'mysql: init OAR database':
      #command => '/usr/bin/mysql oar2 < /usr/lib/oar/database/mysql_structure.sql',
      #unless  => '/usr/bin/mysql -u root --execute="SHOW TABLES;" oar2 | grep jobs',
      #require => [Mysql::Db[$db_name],Package['oar-server']],
      #notify  => Exec['mysql: add OAR default datas', 'mysql: add OAR default admission rules'];
    #'mysql: add OAR default datas':
      #command     => '/usr/bin/mysql oar2 < /usr/lib/oar/database/default_data.sql',
      #refreshonly => true,
      #require     => Exec['mysql: init OAR database'],
      #notify      => Service['oar-server'];
    #'mysql: add OAR default admission rules':
      #command     => '/usr/bin/mysql oar2 < /usr/lib/oar/database/mysql_default_admission_rules.sql',
      #refreshonly => true,
      #require     => Exec['mysql: add OAR default datas'];
  #}

#} # Class:: vagrant::oar::mysql

# Class:: vagrant::oar::pgsql
#
#
class vagrant::oar::pgsql {

  $db_name = "oar2"

  package {
    'postgresql-9.1':
      ensure => installed;
  }

  exec {
    'create database':
      command => '/usr/bin/psql -c "CREATE DATABASE oar2"',
      unless  => '/usr/bin/psql -c "\l" | grep oar2',
      user    => postgres;
    'create role oar':
      command => '/usr/bin/psql -c "CREATE ROLE oar WITH LOGIN PASSWORD \'vagrant\'"',
      unless  => '/usr/bin/psql -c "SELECT rolname FROM pg_roles" | grep oar',
      user    => postgres,
      require => Exec['create database'];
    'grant all privileges on oar2 to vagrant':
      command => '/usr/bin/psql -c "GRANT ALL PRIVILEGES ON DATABASE oar2 TO vagrant"',
      unless  => '/usr/bin/psql -c "SELECT datacl FROM pg_database WHERE datname=\'oar2\'" | grep vagrant',
      user    => postgres,
      require => Exec['create role oar'];
    'pgsql: init OAR database':
      command     => '/usr/bin/psql -U oar -h localhost -d oar2 -f /usr/lib/oar/database/pg_structure.sql',
      unless      => '/usr/bin/psql -U oar -h localhost -d oar2 -c "\dt" | grep jobs',
      environment => "PGPASSWORD=vagrant",
      require     => [Exec['grant all privileges on oar2 to vagrant'],Package['oar-server']],
      notify  => Exec['pgsql: add OAR default datas', 'pgsql: add OAR default admission rules'];
    'pgsql: add OAR default datas':
      command     => '/usr/bin/psql -U oar -h localhost -d oar2 -f /usr/lib/oar/database/default_data.sql',
      environment => "PGPASSWORD=vagrant",
      refreshonly => true,
      require     => Exec['pgsql: init OAR database'],
      notify      => Service['oar-server'];
    'pgsql: add OAR default admission rules':
      command     => '/usr/bin/psql -U oar -h localhost -d oar2 -f /usr/lib/oar/database/pg_default_admission_rules.sql',
      environment => "PGPASSWORD=vagrant",
      refreshonly => true,
      require     => Exec['pgsql: add OAR default datas'];

  }


} # Class:: vagrant::oar::pgsql

# Class:: vagrant::oar::api
#
#
class vagrant::oar::api {

  package {
    'apache2':
      ensure => installed;
  }

  service {
    'apache2':
      ensure => running;
  }

  define apache_module () {
    exec {
      "Enable apache module ${name}":
        command => "/usr/sbin/a2enmod $name",
        unless => "/bin/ls /etc/apache2/mods-enabled | grep '$name'",
        before => Service["apache2"],
        notify => Service["apache2"],
        require => Package["apache2"];
    }
  }

  apache_module {
    ['ident', 'headers', 'rewrite']:
      notify => Service['apache2'];
  }

} # Class:: vagrant::oar::api
