[![Travis](http://travis-ci.org/typekpb/oradown.png?branch=master)](http://travis-ci.org/typekpb/oradown)

# oradown
Enables download of the SSO protected files from the Oracle website.

# Usage

	Usage: oradown.sh [OPTION]... URL
	oradown enables download of the SSO protected files (specified by URL) from the Oracle website.

	Functional arguments:
	  -C, --cookie=LICENSE_COOKIE  name of the license cookie (mandatory)
	  -O, --output=FILE            output FILE (optional)
	  -P, --password=PASSWORD      set the Oracle PASSWORD (mandatory)
	  -U, --username=USERNAME      set the Oracle USERNAME (mandatory)
	  
	Logging and info arguments:
	  -H, --help                   print this help and exit
	  -V, --version                display the version of oradown and exit.

	Examples:

	  Downloads weblogic 12c (oradown downloaded via wget):
	    wget -O - -q https://raw.githubusercontent.com/typekpb/oradown/master/oradown.sh  | \
		bash -s -- --cookie=accept-weblogicserver-server \
		    --username=foo --password=bar \
		    http://download.oracle.com/otn/nt/middleware/12c/12212/fmw_12.2.1.2.0_wls_Disk1_1of1.zip

	    Downloads weblogic 12c (oradown downloaded via curl):
	    curl -s https://raw.githubusercontent.com/typekpb/oradown/master/oradown.sh  | \
		bash -s -- --cookie=accept-weblogicserver-server \
		    --username=foo --password=bar \
		    http://download.oracle.com/otn/nt/middleware/12c/12212/fmw_12.2.1.2.0_wls_Disk1_1of1.zip
      