# installs mailman (private)
class mailman::install {

  package { 'mailman':
    ensure       => installed,
  }

}
