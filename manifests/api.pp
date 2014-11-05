class oar::api {

  include 'oar'

  package {
    'oar-api':
      ensure  => installed,
      require => Class['oar::apt'];
  }

}
