Custom patched DavMail installation instructions
================================================

Build the patched version
-------------------------

The given patch `davmail.patch
<https://github.com/davidjb/davmail/blob/master/davmail.patch>`_ adds the
``davmail.allowedUsers`` option to the configuration which accepts a
comma-separated list of emails to allow into the server.  This protects
(somewhat) from other users who might find your DavMail instance (or are
otherwise on the same shared Exchange instance [such as MS hosted exchange]).

Do the following on a given Linux machine::

    cd /tmp
    wget 'http://downloads.sourceforge.net/project/davmail/davmail/4.5.1/davmail-src-4.5.1-2303.tgz' -O davmail.tgz
    git clone https://github.com/davidjb/djb.davmail.git davmail-davidjb
    tar xf davmail.tgz
    rm davmail.tgz
    cd davmail-src-*
    patch -p1 < ../davmail-davidjb/davmail.patch
    #Modify things if patch didn't work
    ant
    ls -lah dist/

You will now have (assuming all the build process went well) a variety of
builds within the ``dist/`` directory.  Utilise them accordingly.  In the case
of running DavMail on a remote server, then SCP the relevant ``x86`` or
``x86_64`` tgz file across, for example::

    scp dist/davmail-linux-x86_64* [server]:~

Installation on server
----------------------

See below for an example of the ``.private`` file.  So, after logging in::

    sudo yum install git java-1.8.0-openjdk
    cd ~
    git clone https://github.com/davidjb/djb.davmail.git davmail-davidjb
    tar xf davmail-linux-x86_64-*-trunk.tgz
    rm davmail-linux-x86_64-*-trunk.tgz
    mv davmail-linux-x86_64-* davmail
    cd davmail
    cp ../davmail-davidjb/* .
    cat davmail.properties.private >> davmail.properties

    sudo ln -s ~/davmail-davidjb/etc/init.d/davmail /etc/init.d/davmail
    sudo chkconfig --add davmail
    sudo service davmail {start,stop,restart,status}

Update existing version
-----------------------

Update an existing installation on a server::

    cd ~
    pushd davmail-davidjb
    git pull
    #Create davmail.properties.private now and/or p12 keystore
    popd
    tar xf davmail-linux-x86_64-*-trunk.tgz
    rm davmail-linux-x86_64-*-trunk.tgz
    mv davmail davmail.old
    mv davmail-linux-x86_64-* davmail
    cd davmail
    cp ../davmail-davidjb/* .
    cat davmail.properties.private >> davmail.properties
    sudo service davmail restart

Notes
-----

* Use http://testconnectivity.microsoft.com to locate EwsUrl details for
  inclusion into this configuration file. On this page, click ``Outlook
  Autodiscover`` and follow the steps.  On the successful test results page,
  keep expanding nested test results (there are lots of them!) until you get
  to a POST result with a variety of XML details.  There should be a
  ``<EwsUrl>`` tag included -- use this URL.

* Note that the init.d script doesn't log output from the server (save on IO
  cycles).

* The ``.private`` file may contain private information like the
  ``davmail.allowedUsers`` option and email addresses, and also
  ``davmail.ssl.keyPass`` and ``davmail.ssl.keystorePass`` passwords. This is
  kept on the server but not checked in (understandably!). It should look like
  this::

      davmail.allowedUsers = my.email@example.org,another.user@example.com
      davmail.ssl.keyPass = password
      davmail.ssl.keystorePass = password

* Beware of trailing spaces or other characters at the end of the password
  lines above.  If you have any whitespace afterwards, you will tear your
  hair out trying to solve this error::

     Exception creating secured server socket : failed to decrypt safe contents entry: javax.crypto.BadPaddingException: Given final block not properly padded

  Hair-tearing is not fun.

* Convert an official SSL certificate from a CA into P12 format using the
  following::

      openssl pkcs12 -export -in example.org.crt -inkey example.org.key -certfile ca_bundle.crt -out davmail.p12

  The ``Export Password`` you specify will be that which you need to use
  as the ``keyPass`` and ``keystorePass`` options above.

* Generate a self-signed ``davmail.p12`` keyfile using the following::

      keytool -genkey -keyalg rsa -keysize 2048 -storepass password -keystore davmail.p12 -storetype pkcs12 -validity 3650 -dname cn=davmailhostname.company.com,ou=davmail,o=sf,o=net

  Note that ``keytool`` sets both the keypass and the storepass to the same
  value once just ``storepass`` has been configured.  Weren't you glad you
  asked?

Todo
====

* Produce Salt configuration to bootstrap the machine:

  * Install and run yum-cron service on boot
  * Configure SSH for operation on specific port
  * Download patched tgz for davmail
  * Install git, java-1.8.0-openjdk packages
  * Run above instructions for installation
  * Install private settings and data (Pillar) into templated settings file
  * Install init.d script, configure for use
  * Install and run davmail service on boot

