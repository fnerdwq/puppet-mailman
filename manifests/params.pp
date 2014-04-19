# set flavor specific variables (private)
class mailman::params {

  case $::osfamily {
    'Debian': {
      $group = 'list'
      $apache_user = 'www-data'
    }
    'RedHat': {
      $group = 'mailman'
      $apache_user = 'apache'
    }
    default:  {
      fail("Module ${module_name} is not supported on ${::operatingsystem}/${::osfamily}")
    }
  }
}
