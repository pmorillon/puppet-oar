# Module:: oar
# Manifest:: init.pp
#

import "definitions/*.pp"
import "classes/*.pp"

# Class:: oar ($version = "2.5")
#
#
class oar ($version = "2.5") {

    include "oar::dependencies"

    oar::configure_repo {
      "oar":
        version => $version,
        require => Package["curl"];
    }

    package {
      ["oar-common", "oar-doc"]:
        ensure  => installed;
    }

} # Class:: oar ($version = "2.5")


# Class:: oar::dependencies
#
#
class oar::dependencies {

  package {
    ["curl"]:
      ensure  => installed;
  }

} # Class:: oar::dependencies

