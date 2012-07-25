# Module:: oar
# Manifest:: init.pp
#

import "definitions/*.pp"
import "classes/*.pp"

# Class:: oar ($version = "2.5")
#
#
class oar ($version = "2.5", $db = "mysql", $snapshots = false) {

    oar::configure_repo {
      "oar":
        version   => $version,
        snapshots => $snapshots;
    }

    package {
      ["oar-common", "oar-doc"]:
        ensure  => installed,
        require => Oar::Configure_repo["oar"];
    }

} # Class:: oar ($version = "2.5")

