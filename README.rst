-----------
**last.sh**
-----------

last.sh is a simple shell application to display your *currently playing* last.fm song.

Prerequisites & requirements
----------------------------

- jq

Installation
------------

- git::

    git clone https://github.com/runarsf/last.sh

- git/ssh::

    git clone git@github.com:runarsf/last.sh.git

Usage
-----

 ``last.sh [args]``

 -h            Help dialog.
 -r            Run.
 -d            Delete credentials.
 -c            Set credentials, overwrites already existing.
 -a            Relay API information. Returns formatted reply in cleartext."
 -q            Relay API information. Returns json."
 -p            Polybar mode, returns output once.

Q
-

- What is "API mode", and how do I use it?

  - API mode basically just outputs (un)formatted data.

  .. code-block:: bash

    [last.sh] echo "Queen, Bohemian Rhapsody" | grep "`last.sh -a album`"
    Queen, **\ Bohemian Rhapsody**

- If username or API key is not set before running in "API mode", script will always exit with no output. This is in order not to get a false reply.

  - To fix this, run ``last.sh -c`` to set credentials.

- If output is longer than terminal window, a new line will be added each poll. To circumvent this, the output information is reduced;

  - ``--> artist : track ( album )`` > ``--> artist : track`` > ``--> track``. If the track name itself is too long to display, an error will be displayed.

- Credentials not being removed from environment. Credentials are only stored in /etc/environment, the cause might be how your machine handles this.

  - Try machine restart, or run ``last.sh -c`` to set new credentials.
