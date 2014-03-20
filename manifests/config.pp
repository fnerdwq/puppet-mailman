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

  # we have to run this as user, otherwise alias.db might be crated with 640 root:list!
  exec {'create site list':
    command   => "newlist -q ${site_list} ${mailman::site_list_admin} ${mailman::site_list_pw}",
    unless    => "list_lists -b | grep -q '^${site_list}$'",
    path      => ['/bin', '/usr/sbin'],
    require   => File['/etc/mailman/mm_cfg.py'],
    notify    => Exec['set master password', '/etc/mailman/mm_cfg.py'],
  }

  # only initially create master/site liste pw
  exec {'set master password':
    command     => "mmsitepass ${mailman::master_list_pw}",
    refreshonly => true,
    path        => ['/usr/sbin'],
    require     => File['/etc/mailman/mm_cfg.py'],
  }
  exec {'set create-list password':
    command     => "mmsitepass -c ${mailman::create_list_pw}",
    refreshonly => true,
    path        => ['/usr/sbin'],
    require     => File['/etc/mailman/mm_cfg.py'],
  }


  # ensure correct right's on alias.db, otherwise mailman website cannot
  # create lists (bug in Debian?
  if $mta == 'Postfix' {

    # we have to have apache included here
    include apache

    file {'/var/lib/mailman/data/alias.db':
      ensure  => present,
      owner   => 'www-data',
      group   => 'list',
      mode    => '0660',
      require => [ Exec['create site list'], Class['apache'] ],
    }
  }



}
