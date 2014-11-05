class oar::node {

  include 'oar'

  package {
    'oar-node':
      ensure  => installed,
      require => Class['oar::apt'];
  }

  service {
    'oar-node':
      enable  => true,
      require => Package['oar-node'];
  }

}
