class oar::user {

  include 'oar'

  package {
    'oar-user':
      ensure  => installed,
      require => Class['oar::apt'];
  }

  if $oar::major_release == '2.5' {
    package {
      'oar db connector':
        name    => $oar::db ? {
          'mysql' => 'oar-user-mysql',
          'pgsql' => 'oar-user-pgsql'
        },
        ensure  => installed,
        require => Package['oar-user'];
    }
  }

}
