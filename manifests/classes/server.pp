# Module:: oar
# Manifest:: classes/server.pp
#

# Class:: oar::server ($version = "2.5") inherits oar
#
#
class oar::server ($version = "2.5", $db = "mysql") {

  # Allow to install frontend and server on the same machine
  if !defined(Class["oar"]) {
    class {
      "oar":
        version => $version,
        db      => $db;
    }
  }

  case $operatingsystem {
    debian, ubuntu, centos: {
      include "oar::server::${operatingsystem}"
    }
    default: {
      err "${operatingsystem} not supported yet"
    }
  }

} # Class:: oar::server ($version = "2.5", $db = "mysql") inherits oar


# Class:: oar::server::debian inherits oar::server::base
#
#
class oar::server::debian inherits oar::server::base {

  package { "taktuk": ensure => installed; }

} # Class:: oar::server::debian inherits oar::server::base

# Class:: oar::server::base inherits oar
#
#
class oar::server::base inherits oar {

  package {
    ["oar-server", "oar-admin"]:
      ensure  => installed,
      require => Oar::Configure_repo["oar"];
  }

  package {
    "db-server":
      name    => $oar::db ? {
        "mysql" => "oar-server-mysql",
        "pgsql" => "oar-server-pgsql",
      },
      ensure  => installed,
      require => Oar::Configure_repo["oar"];
  }

   service {
    "oar-server":
      ensure => running,
      pattern => "Almighty",
      enable => true,
      require => Package["oar-server"];
  }

} # Class:: oar::server::base inherits oar

