# Module:: oar
# Manifest:: definitions/repo.pp
#

# Define:: oar::configure_repo
# Args:: $version
#
define oar::configure_repo($version) {

  case $operatingsystem {
    debian: {
      file {
        "/etc/apt/sources.list.d/oar.list":
          ensure  => file,
          mode    => 644, owner => root, group => root,
          content => template("oar/repos/debian/oar.list.erb"),
          notify  => Exec["APT sources update", "Add APT key"];
      }

      exec {
        "APT sources update":
          path        => "/usr/bin:/usr/sbin:/bin",
          command     => "apt-get update",
          refreshonly => true,
          require     => Exec["Add APT key"];
        "Add APT key":
          path        => "/usr/bin:/usr/sbin:/bin",
          command     => "curl http://oar-ftp.imag.fr/oar/oarmaster.asc | sudo apt-key add -",
          refreshonly => true;
      }
    }
    centos: {

    }
    default: {
      err "${operatingsystem} not supported yet"
    }
  }

} # Define: oar::configure_repo

