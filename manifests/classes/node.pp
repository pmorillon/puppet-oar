# Module:: oar
# Manifest:: classes/node.pp
#

# Class:: oar::node ($version = "2.5")
#
#
class oar::node ($version = "2.5") {

  class {
    "oar":
      version => $version;
  }

  case $operatingsystem {
    debian,ubuntu: {
      include "oar::node::${operatingsystem}"
    }
    default: {
      err "${operatingsystem} not supported yet"
    }
  }

} # Class:: oar::node ($version = "2.5")

# Class:: oar::node::ubuntu
#
#
class oar::node::ubuntu {

  include "oar::node::debian"

} # Class:: oar::node::ubuntu

# Class:: oar::node::debian inherits oar::node::base
#
#
class oar::node::debian inherits oar::node::base {
  

} # Class:: oar::node::debian inherits oar::node::base

# Class:: oar::node::base inherits oar
#
#
class oar::node::base inherits oar {
  
  package {
    "oar-node":
      ensure  => installed,
      require => Oar::Configure_repo["oar"];
  }

} # Class:: oar::node::base inherits oar

