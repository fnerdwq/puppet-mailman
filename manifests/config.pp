# configures mailman (private)
class mailman::config {

  $url_pattern     = $mailman::url_pattern
  $email_host      = $mailman::email_host
  $url_host        = $mailman::url_host
  $server_language = $mailman::server_language
  $mta             = $mailman::mta
  $site_list       = $mailman::site_list

  file { '/etc/mailman/mm_cfg.py':
    content => template('mailman/mm_cfg.py.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
  }

  exec {'create site list':
    command   => "newlist -q ${site_list} ${mailman::site_list_admin} ${mailman::site_list_pw}",
    unless    => "list_lists -b | grep -q '^${site_list}$'",
    path      => ['/bin', '/usr/sbin'],
    require   => File['/etc/mailman/mm_cfg.py'],
  }


}
