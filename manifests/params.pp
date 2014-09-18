# set flavor specific variables (private)
class mailman::params {

  $url_pattern        = 'http://%s/cgi-bin/mailman/'
  $email_host         = $::fqdn
  $url_host           = $::fqdn
  $server_language    = 'en'
  $mta                = undef
  $smtpport           = undef
  $public_archive_url = undef
  $site_list          = 'mailman'
  $site_list_admin    = "root@${::fqdn}"
  $site_list_pw       = 'initial'
  $master_list_pw     = 'master'
  $create_list_pw     = 'create'
  $lists              = {}
  $lists_defaults     = {}

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
