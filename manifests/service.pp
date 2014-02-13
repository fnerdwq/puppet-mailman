# manages the mailman service (private)
class mailman::service {

  service{ 'mailman':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => false,
  }

}
