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
# [*group*]
#   Group the mailman runs under.
#   *Optional* (default depends on OS)
#
# [*apache_user*]
#   User Apache runs under.
#   *Optional* (default depends on OS)
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
  $url_pattern     = 'http://%s/cgi-bin/mailman/',
  $email_host      = $::fqdn,
  $url_host        = $::fqdn,
  $server_language = 'en',
  $mta             = undef,
  $smtpport        = undef,
  $site_list       = 'mailman',
  $site_list_admin = "root@${::fqdn}",
  $site_list_pw    = 'initial',
  $master_list_pw  = 'master',
  $create_list_pw  = 'create',
  $group           = $mailman::params::group,
  $apache_group    = $mailman::params::apache_group,
) inherits mailman::params {

  validate_string($url_pattern)
  validate_string($email_host)
  validate_string($url_host)
  validate_string($server_language)
  validate_string($site_list)
  validate_string($site_list_admin)
  validate_string($site_list_pw)
  validate_string($site_list_pw)
  validate_string($master_list_pw)
  validate_string($create_list_pw)


  contain(mailman::install)
  contain(mailman::config)
  contain(mailman::service)

  Class['mailman::install']
  -> Class['mailman::config']
  ~> Class['mailman::service']

}

