# Module:: oar
# Manifest:: server.pp

class oar::server {

  include 'oar'

  package {
    'oar-server':
      ensure   => installed,
      require  => Class['oar::apt'];
    'db-server':
      name => $oar::db ? {
        'mysql' => 'oar-server-mysql',
        'pgsql' => 'oar-server-pgsql',
      },
      ensure  => installed,
      require => Class['oar::apt'];
  }

  service {
    'oar-server':
      ensure => running,
      pattern => 'Almighty',
      enable => true,
      hasstatus => false,
      status    => 'ps -u oar | grep Almighty',
      require => Package['oar-server'];
  }


}
