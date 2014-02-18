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
# [*site_list*]
#   Name of site list to create.
#   *Optional* (defaults to mailman)
#
# [*site_liste_admin*]
#   Admin emai for site list.
#   *Optional* (defaults to root@$::fqdn)
#
# [*site_list_pw*]
#   Site liste password.
#   *Optional* (defaults to initial)
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

