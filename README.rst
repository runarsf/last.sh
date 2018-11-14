-----------
**last.sh**
-----------

last.sh is a simple shell application to display your currently playing last.fm song.

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

Known issues // Fixes
---------------------

- If output is longer than terminal window, a new line will be added each poll. To circumvent this, the output information is reduced;

  - ``--> artist : track ( album )`` > ``--> artist : track`` > ``--> track``. If the track name itself is too long to display, an error will be displayed.

- Credentials not being removed from environment. Try machine restart, only known place of saving is /etc/environment
