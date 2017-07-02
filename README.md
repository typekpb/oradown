[![Travis](http://travis-ci.org/typekpb/oradown.png?branch=master)](http://travis-ci.org/typekpb/oradown)

# oradown
Enables download of the SSO protected files from the Oracle website.

# Usage

	Usage: $cmdname [OPTION]... URL
	oradown enables download of the SSO protected files (specified by URL) from the Oracle website.

	Functional arguments:
	  -C, --cookie=LICENSE_COOKIE  name of the license cookie (mandatory)
	  -O, --output=FILE            output FILE (optional)
	  -P, --password=PASSWORD      set the Oracle PASSWORD (mandatory)
	  -U, --username=USERNAME      set the Oracle USERNAME (mandatory)
	  
	Logging and info arguments:
	  -H, --help                   print this help and exit
	  -V, --version                display the version of wtfc and exit.

	Examples:

	  Downloads weblogic 12c:
	  ./oradown.sh --username=foo --password=bar \
	  --cookie=accept-weblogicserver-cookie \
	  --output=wls12c.zip \
	  http://download.oracle.com/otn/nt/middleware/12c/12212/fmw_12.2.1.2.0_wls_Disk1_1of1.zip
