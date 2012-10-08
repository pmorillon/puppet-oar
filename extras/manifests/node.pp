# OAR node installation with puppet and vagrant

$oar_version = "2.5"
$oar_home    = "/var/lib/oar"
$files_path  = "/srv/vagrant-puppet/manifests/files"

class {
  "oar::node":
    version => "2.5";
}

File { require => Package["oar-node"] }

file {
  "${oar_home}/.ssh":
    ensure  => directory,
    mode    => 755, owner => oar, group => oar;
  "${oar_home}/.ssh/authorized_keys":
    ensure  => file,
    mode    => 644, owner => oar, group => oar,
    source  => "${files_path}/keys/node/authorized_keys";
  "${oar_home}/.ssh/id_rsa":
    ensure  => file,
    mode    => 600, owner => oar, group => oar,
    source  => "${files_path}/keys/node/oar/id_rsa";
  "${oar_home}/.ssh/id_rsa.pub":
    ensure  => file,
    mode    => 644, owner => oar, group => oar,
    source  => "${files_path}/keys/node/oar/id_rsa.pub";
  "${oar_home}/.ssh/oarnodesetting_ssh.key":
    ensure  => file,
    mode    => 600, owner => oar, group => oar,
    source  => "${files_path}/keys/node/oarnodessetting/id_rsa";
  "${oar_home}/.ssh/oarnodesetting_ssh.key.pub":
    ensure  => file,
    mode    => 644, owner => oar, group => oar,
    source  => "${files_path}/keys/node/oarnodessetting/id_rsa.pub";
  "/etc/default/oar-node":
    ensure  => file,
    mode    => 644, owner => root, group => root,
    source  =>  "${files_path}/conf/node/oar-node";
  "/etc/hosts":
    ensure  => file,
    mode    => 644, owner => root, group => root,
    content => template("${files_path}/conf/node/hosts.erb");
  "/etc/hostname":
    ensure  => file,
    mode    => 644, owner => root, group => root,
    content => template("${files_path}/conf/node/hostname.erb"),
    notify  => Exec["/etc/init.d/hostname.sh"];
}

exec {
  "/etc/init.d/hostname.sh":
    refreshonly => true,
    notify      => Exec["/etc/init.d/oar-node restart"];
  "/etc/init.d/oar-node restart":
    refreshonly => true;
}

if ($operatingsystem == "Ubuntu") {
  Exec["/etc/init.d/hostname.sh"] { command => "/etc/init.d/hostname restart" }
}


