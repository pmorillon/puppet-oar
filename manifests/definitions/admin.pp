# Module:: oar
# Manifest:: definitions/admin.pp
#

# Define:: oar::property
# Args:: $ensure, $options = ""
#
define oar::property($ensure, $options = "") {
  case $ensure {
    present: {
      exec {
        "oarproperty -a ${name} ${options}":
          path    => "/usr/bin:/usr/sbin:/bin",
          unless  => "oarproperty -l | grep -e '^${name}$'",
          require => Service["oar-server"];
      }
    }
    absent: {
      exec {
        "oarproperty -d ${name}":
          path    => "/usr/bin:/usr/sbin:/bin",
          onlyif  => "oarproperty -l | grep -e '^${name}$'",
          require => Service["oar-server"];
      }

    }
    default: {
      fail "Invalid 'ensure' value '$ensure' for oar::property"
    }
  }
} # Define: oar::property

