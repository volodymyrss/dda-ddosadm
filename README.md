# dda-ddosadm


* downloading with rsync (over rsync protocol) or wget (over http crawl) is ridiculously slow because of overhead for large number of files
* rsync over ssh, even better, tarred stream over ssh work qutie well, but transfer channels for this fall-off remarkably often - they are usually general-purpose basion nodes, and it is difficult to make sure autofs works. When they fall off, analysis breaks. Also, it's not idea.
* ISDC w3browse allows transfer of tarred data, but only with email - not usable for automation.
* HEASARC w3browse may allow automated tarred transfer with some manipulation

ideally, we could have a RESTful server providing data by token. It is a small effort to develop. 
