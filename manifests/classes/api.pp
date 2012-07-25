# Module:: oar
# Manifest:: classes/api.pp
#

# Class:: oar::api ($version = "2.5")
#
#
class oar::api ($version = "2.5", $snapshots = false) {

  # Allow to install frontend and server on the same machine
  if !defined(Class["oar"]) {
    class {
      "oar":
        version   => $version,
        snapshots => $snapshots;
    }
  }

  case $operatingsystem {
    debian,ubuntu: {
      include "oar::api::${operatingsystem}"
    }
    default: {
      err "${operatingsystem} not supported yet"
    }
  }

} # Class:: oar::api ($version = "2.5")

# Class:: oar::api::debian inherits oar::api::base
#
#
class oar::api::debian inherits oar::api::base {

} # Class:: oar::api::debian inherits oar::api::base

# Class:: oar::api::ubuntu inherits oar::api::ubuntu
#
#
class oar::api::ubuntu inherits oar::api::base {

  include "oar::api::debian"

} # Class:: oar::api::ubuntu inherits oar::api::base

# Class:: oar::api::base inherits oar
#
#
class oar::api::base inherits oar {

  package {
    "oar-api":
      ensure  => installed,
      require => Oar::Configure_repo["oar"];
  }

} # Class:: oar::api::base inherits oar
