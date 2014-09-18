# configures mailman lists (private)
class mailman::listconfig {

  create_resources('maillist_config',$mailman::lists, $mailman::lists_defaults)
}
