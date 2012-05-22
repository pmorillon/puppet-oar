# Module:: oar
# Manifest:: classes/frontend.pp
#

# Class:: oar::frontend ($version = "2.5")
#
#
class oar::frontend ($version = "2.5") {

  # Allow to install frontend and server on the same machine
  if !defined(Class["oar"]) {
    class { "oar": version => $version; }
  }

  case $operatingsystem {
    debian, ubuntu, centos: {
      include "oar::frontend::${operatingsystem}"
    }
    default: {
      err "${operatingsystem} not supported yet"
    }
  }

} # Class:: oar::frontend ($version = "2.5")

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
      "oar-user-mysql":
        ensure  => installed,
        require => Package["oar-user"];
    }
  }

} # Class:: oar::frontend::base inherits oar
