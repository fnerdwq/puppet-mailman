#puppet-mailman

####Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What mailman affects](#what-mailman-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with mailman](#beginning-with-mailman)
4. [Usage](#usage)
5. [Limitations](#limitations)
6. [TODOs](#todos)

##Overview

This small mailman module installs and configures mailman.
Apache should be installed first (for Postfix 'www-data' has to 
exists).

Working on Debian wheezy.

Written for Puppet >= 3.4.0.

##Module Description

See [Overview](#overview) for now.

##Setup

###What mailman affects

* Installs mailman.
* Creates admin list *site_list*

###Setup Requirements

You have to take care about the vhost configuration yourself.
E.g. use the puppetlabs-apache module.
	
###Beginning with mailman	

Simply include it.

##Usage

Just include the module by 

```puppet
include mailman
```

##Limitations:

Tested only on 
* Debian 7
so far.

Puppet Version >= 3.4.0, due to specific hiera/*contain* usage.

##TODOs:

* Make it work on RedHat like systems.
* Include apache configuration?
* Dependency on www-data user should be cleaner.
* Make more configurable.
* ... suggestions? Open an issue on github...
