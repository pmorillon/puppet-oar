# Module:: oar
# Manifest:: definitions/repo.pp
#
# Author:: Pascal Morillon (<pascal.morillon@irisa.fr>)
# Date:: Mon May 21 14:50:22 +0200 2012
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
          notify  => Exec["APT sources update"];
      }

      exec {
        "APT sources update":
          path        => "/usr/bin:/usr/sbin:/bin",
          command     => "apt-get update",
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

