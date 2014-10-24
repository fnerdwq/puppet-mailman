# == Class: mailman
#
# This installs and configures mailman.
#
# This works on Debian.
# Puppet Version >= 3.4.0
#
# === Parameters
#
# [*url_pattern*]
#   mm_cfg.py URL_PATTERN setting
#   *Optional* (defaults to http://%s/cgi-bin/mailman/)
#
# [*email_host*]
#   Default domain for email addresses of newly created MLs
#   *Optional* (defaults to $::fqdn)
#
# [*url_host*]
#   Default host for web interface of newly created MLs
#   *Optional* (defaults to $::fqdnf)
#
# [*server_language*]
#   The default language for this server.
#   *Optional* (defaults to en)
#
# [*mta*]
#   mm_cfg.py MTA setting
#   *Optional* (defaults to undef)
#
# [*smtpport*]
#   Optional smtp port for delivery through SMTPDirect
#   Usefull for AMaViS usage (set it to 10025 then)
#   *Optional* (defaults to undef)
#
# [*public_archive_url*]
#   The url template for the public archives.
#   *Optional* (defaults to undef)
#
# [*site_list*]
#   Name of site list to create.
#   *Optional* (defaults to mailman)
#
# [*site_liste_admin*]
#   Admin emai for site list.
#   *Optional* (defaults to root@$::fqdn)
#
# [*site_list_pw*]
#   Site list password.
#   *Optional* (defaults to initial)
#
# [*master_list_pw*]
#   Master list password.
#   *Optional* (defaults to master)
#
# [*crate_list_pw*]
#   Create list password.
#   *Optional* (defaults to create)
#
# [*lists*]
#   Create this lists (via maillist_config type).
#   *Optional* (defaults to {})
#
# [*lists_defaults*]
#   Default parameters vor lists parameter.
#   *Optional* (defaults to {})
#
# [*user*]
#   User the mailman runs under.
#   *Optional* (default depends on OS)
#
# [*group*]
#   Group the mailman runs under.
#   *Optional* (default depends on OS)
#
# [*apache_group*]
#   Group Apache runs under.
#   *Optional* (default depends on OS)
#
# [*backup_members*]
#   Install cron script, which dayly backups members.
#   *Optional* (defaults to false)
#
# [*backup_members_dir*]
#   Where the member backup files are stored.
#   *Optional* (defaults to /var/lib/mailman/backup)
#
# === Examples
#
# include mailman
#
# === Authors
#
# Frederik Wagner <wagner@wagit.de>
#
# === Copyright
#
# Copyright 2014 Frederik Wagner
#
class mailman (
  $url_pattern        = $mailman::params::url_pattern,
  $email_host         = $mailman::params::email_host,
  $url_host           = $mailman::params::url_host,
  $server_language    = $mailman::params::server_language,
  $mta                = $mailman::params::mta,
  $smtpport           = $mailman::params::smtpport,
  $public_archive_url = $mailman::params::public_archive_url,
  $site_list          = $mailman::params::site_list,
  $site_list_admin    = $mailman::params::site_list_admin,
  $site_list_pw       = $mailman::params::site_list_pw,
  $master_list_pw     = $mailman::params::master_list_pw,
  $create_list_pw     = $mailman::params::create_list_pw,
  $lists              = $mailman::params::lists,
  $lists_defaults     = $mailman::params::lists_defaults,
  $user               = $mailman::params::user,
  $group              = $mailman::params::group,
  $apache_group       = $mailman::params::apache_group,
  $backup_members     = $mailman::params::backup_members,
  $backup_members_dir = $mailman::params::backup_members_dir,
) inherits mailman::params {

  validate_string($url_pattern)
  validate_string($email_host)
  validate_string($url_host)
  validate_string($server_language)
  validate_string($public_archive_url)
  validate_string($site_list)
  validate_string($site_list_admin)
  validate_string($site_list_pw)
  validate_string($site_list_pw)
  validate_string($master_list_pw)
  validate_string($create_list_pw)
  validate_hash($lists)
  validate_hash($lists_defaults)
  validate_string($user)
  validate_string($group)
  validate_string($apache_group)
  validate_bool($backup_members)
  validate_absolute_path($backup_members_dir)

  contain(mailman::install)
  contain(mailman::config)
  contain(mailman::listconfig)
  contain(mailman::service)

  Class['mailman::install']
  -> Class['mailman::config']
  ~> Class['mailman::service']

  Class['mailman::config'] ->
  Class['mailman::listconfig']

}

