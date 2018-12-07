Custom patched DavMail installation instructions
================================================

.. image:: https://travis-ci.org/davidjb/djb.davmail.svg?branch=master
   :target: https://travis-ci.org/davidjb/djb.davmail


The patch
---------

The given patch `davmail-userwhitelist.patch
<https://github.com/davidjb/djb.davmail/blob/master/patches/davmail-userwhitelist.patch>`_ adds the
``davmail.allowedUsers`` option to the configuration which accepts a
comma-separated list of emails to allow into the server.  This protects
(somewhat) from other users who might find your DavMail instance (or are
otherwise on the same shared Exchange instance [such as MS hosted exchange]).

Building
--------

You can either manually patch Davmail's sources using the provided patch, or
use Docker to build a .deb for you.  This will always build the latest version
of Davmail from the Debian repositories (ensuring it is suitably packaged with
init scripts and the like, unlike the .deb that comes from the developer).

#. Ensure `Docker <https://docs.docker.com/>`_ and `Docker Compose
   <https://docs.docker.com/compose>`_ are installed.

#. Run the following::

       git clone https://github.com/davidjb/djb.davmail.git
       cd djb.davmail
       docker-compose up

#. Enjoy your new package, available in the `build/` directory.

If you're not into Docker, then you can use the ``davmail-build.sh``
script directly on your own Debian VM.  You'll need to ensure you have
set up the basic dependencies of building debs first; see the
``Dockerfile`` file for more information.

Installation on server
----------------------

#. Copy package produced above to server.  Install it with::

      sudo apt update && sudo apt install -y gdebi0-core
      sudo gdebi ./davmail_*.deb

#. Edit ``/etc/davmail.properties`` to configure your Davmail instance

#. Add security certificates into the appropriate ``.p12`` keystore

#. Configure the OS accordingly to permit Davmail to listen on privileged
   ports, either:

   #. Run it as root (not recommended), or
   #. Enable capabilities::

          sudo apt install -y libcap2-bin
          sudo setcap 'cap_net_bind_service=+ep' $(readlink -f $(which java))

#. Unmask the service::

       sudo systemctl unmask davmail

#. Control Davmail with::

       sudo systemctl {start,stop,restart,status} davmail

You can reinstall a new package straight over the top when required.

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
  ``davmail.ssl.keyPass`` and ``davmail.ssl.keystorePass`` passwords. It
  should look like this::

      davmail.allowedUsers = my.email@example.org,another.user@example.com
      davmail.ssl.keyPass = password
      davmail.ssl.keystorePass = password

* Beware of trailing spaces or other characters at the end of the password
  lines above.  If you have any whitespace afterwards, you will tear your
  hair out trying to solve this error::

     Exception creating secured server socket : failed to decrypt safe contents entry: javax.crypto.BadPaddingException: Given final block not properly padded

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
