# Module:: oar
# Manifest:: init.pp
#

class oar(
  $version = "2.5.4-1",
  $db = "pgsql",
  $suite = "stable"
) {

  $major_release = $version ? {
    'latest' => '2.5',
    default => inline_template('<%= @version.gsub(/(\d+\.\d+).*$/,\'\1\') %>')
  }

  $home_path = '/var/lib/oar'

  case $operatingsystem {
    debian:{
      class {
        'oar::apt':
      }
    }
    default:{
      err "${operatingsystem} not supported !"
    }
  }


}
