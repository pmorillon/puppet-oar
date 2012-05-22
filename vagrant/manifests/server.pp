# OAR server installation with puppet and vagrant

$oar_version = "2.5"

class { "oar::server": version => $oar_version; }
class { "oar::frontend": version => $oar_version; }

