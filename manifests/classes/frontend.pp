# Module:: oar
# Manifest:: classes/frontend.pp
#

# Class:: oar::frontend ($version = "2.5", $db = "mysql")
#
#
class oar::frontend ($version = "2.5", $db = "mysql", $snapshots = false) {

  # Allow to install frontend and server on the same machine
  if !defined(Class["oar"]) {
    class {
      "oar":
        version   => $version,
        db        => $db,
        snapshots => $snapshots;
    }
  }

  case $operatingsystem {
    debian, ubuntu: {
      include "oar::frontend::${operatingsystem}"
    }
    default: {
      err "${operatingsystem} not supported yet"
    }
  }

} # Class:: oar::frontend ($version = "2.5", $db = "mysql")

# Class:: oar::frontend::ubuntu
#
#
class oar::frontend::ubuntu {

  include "oar::frontend::debian"

} # Class:: oar::frontend::ubuntu

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
    ["oar-user"]:
      ensure  => installed,
      require => Oar::Configure_repo["oar"];
  }

  if $oar::version == "2.5" {
    package {
      ["oar-user-mysql","oar-user-pgsql"]:
        ensure  => installed,
        require => Package["oar-user"];
    }
  }

} # Class:: oar::frontend::base inherits oar

