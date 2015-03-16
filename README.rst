Custom patched DavMail installation instructions
================================================

The patch
---------

The given patch `davmail-userwhitelist.patch
<https://github.com/davidjb/djb.davmail/blob/master/davmail-userwhitelist.patch>`_ adds the
``davmail.allowedUsers`` option to the configuration which accepts a
comma-separated list of emails to allow into the server.  This protects
(somewhat) from other users who might find your DavMail instance (or are
otherwise on the same shared Exchange instance [such as MS hosted exchange]).

Building the patched version
----------------------------

You can either manually patch Davmail's sources using the provided patch, or
use Vagrant to build a CentOS/RHEL/Amazon Linux compatible RPM like so::

    vagrant up

This will download a CentOS 6.x image, obtain the SRPM for Davmail, patch
accordingly (for chkconfig, dependendies, the above user patch) and export the
RPMs.  These can be then copied to the server of your choice.

Installation on server
----------------------

#. Copy RPM produced above to server
#. Edit ``/etc/davmail.properties`` to configure your Davmail instance
#. Control Davmail with::

   sudo service davmail {start,stop,restart,status}

You can reinstall a new RPM straight over the top when required.

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

Todo
====

* Produce Salt configuration to bootstrap the machine:

  * Install and run yum-cron service on boot
  * Configure SSH for operation on specific port
  * Patch/install RPMs
