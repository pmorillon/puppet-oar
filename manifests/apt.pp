# Module:: oar
# Manifest:: apt.pp

class oar::apt {

  include 'oar'

  file {
    '/etc/apt/sources.list.d/oar.list':
      ensure  => file,
      mode    => '0644',
      owner   => root,
      group   => root,
      content => template('oar/repos/debian/oar.list.erb'),
      notify  => Exec['OAR APT sources update'];
    '/etc/apt/preferences.d/oar.pref':
      ensure  => file,
      mode    => '0644',
      owner   => root,
      group   => root,
      content => template('oar/repos/debian/oar.pref.erb'),
      notify  => Exec['OAR APT sources update'];
  }

  exec {
    'OAR APT sources update':
      path        => '/usr/bin:/usr/sbin:/bin',
      command     => 'apt-get update',
      refreshonly => true;
    'Add APT key':
      path        => '/usr/bin:/usr/sbin:/bin',
      command     => 'wget http://oar-ftp.imag.fr/oar/oarmaster.asc && sudo apt-key add /tmp/oarmaster.asc',
      unless      => 'apt-key list | grep oar',
      cwd         => '/tmp',
      notify      => Exec['OAR APT sources update'];
  }

}
