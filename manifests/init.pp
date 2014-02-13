# manages mailman
class mailman (
  $url_pattern     = 'http://%s/cgi-bin/mailman/',
  $email_host      = $::fqdn,
  $url_host        = $::fqdn,
  $server_language = 'en',
  $mta             = undef,
  $site_list       = 'mailman',
  $site_list_admin = "root@${::fqdn}",
  $site_list_pw    = 'initial',
) {

  validate_string($url_pattern)
  validate_string($email_host)
  validate_string($url_host)
  validate_string($server_language)
  validate_string($mta)
  validate_string($site_list)
  validate_string($site_list_admin)
  validate_string($site_list_pw)


  contain(mailman::install)
  contain(mailman::config)
  contain(mailman::service)

  Class['mailman::install']
  -> Class['mailman::config']
  ~> Class['mailman::service']

}

