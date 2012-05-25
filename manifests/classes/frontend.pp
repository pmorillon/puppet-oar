# Module:: oar
# Manifest:: classes/frontend.pp
#

# Class:: oar::frontend ($version = "2.5", $db = "mysql")
#
#
class oar::frontend ($version = "2.5", $db = "mysql") {

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
      include "oar::frontend::${operatingsystem}"
    }
    default: {
      err "${operatingsystem} not supported yet"
    }
  }

} # Class:: oar::frontend ($version = "2.5", $db = "mysql")

# Class:: oar::frontend::debian inherits oar::frontend::base
#
#
class oar::frontend::debian inherits oar::frontend::base {

} # Class:: oar::frontend::debian inherits oar::frontend::base

# Class:: oar::frontend::base inherits oar
#
#
class oar::frontend::base inherits oar {

  package {
    ["oar-user", "oar-node"]:
      ensure  => installed,
      require => Oar::Configure_repo["oar"];
  }

  if $oar::version == "2.5" {
    package {
      "db-server":
      name    => $oar::db ? {
        "mysql" => "oar-user-mysql",
        "pgsql" => "oar-user-pgsql",
      },
      ensure  => installed,
      require => Package["oar-user"];
    }
  }

} # Class:: oar::frontend::base inherits oar

