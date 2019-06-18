#!/usr/bin/env bash
set -e

cmdname="${0##*/}"

VERSION=0.0.4

echoto() {
    # print to stderr or to stdout
    out=$1
    shift 1

    if ([ "${out}" -eq 2 ]); then
        printf "$@" >&2
    else
        # stdout can be silenced only
        if [ "${QUIET}" -eq 0 ]; then
            printf "$@"
        fi
    fi
}

usage() {
    OUTPUT=`cat <<EOF
Usage: $cmdname [OPTION]... URL
oradown enables download of the SSO protected files (specified by URL) from the Oracle website.

Functional arguments:
  -C, --cookie=LICENSE_COOKIE  name of the license cookie (mandatory)
  -O, --output=FILE            output FILE (optional)
  -P, --password=PASSWORD      set the Oracle PASSWORD (optional)
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
EOF
`

    # print to stderr (for exit status > 0), otherwise to stdout
    if ([ "$1" -gt 0 ]); then
        echo "${OUTPUT}" >&2
    else
        echo "${OUTPUT}"
    fi

    exit $1
}

version() {
    echo "oradown version: ${VERSION}"
    exit 0
}

check_cmds_present() {
    eval "curl --version >/dev/null 2>&1"
    if [ $? -eq 127 ]; then
        echo "ERROR: curl command not present! Please install it first."
        exit 1
    fi
    eval "xmllint --version >/dev/null 2>&1"
    if [ $? -eq 127 ]; then
        echo "ERROR: xmllint command not present! Please install it first."
        exit 1
    fi
}

user_agent() {
    # from https://gist.github.com/kopiro/837213c14641ae82b860
    USER_AGENTS=( \
    'Mozilla/6.0 (Windows NT 6.2; WOW64; rv:16.0.1) Gecko/20121011 Firefox/16.0.1' \
    'Mozilla/5.0 (Windows NT 6.2; WOW64; rv:16.0.1) Gecko/20121011 Firefox/16.0.1' \
    'Mozilla/5.0 (Windows NT 6.2; Win64; x64; rv:16.0.1) Gecko/20121011 Firefox/16.0.1' \
    'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:14.0) Gecko/20120405 Firefox/14.0a1' \
    'Mozilla/5.0 (Windows NT 6.1; rv:14.0) Gecko/20120405 Firefox/14.0a1' \
    'Mozilla/5.0 (Windows NT 5.1; rv:14.0) Gecko/20120405 Firefox/14.0a1' \
    'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.13 (KHTML, like Gecko) Chrome/24.0.1290.1 Safari/537.13' \
    'Mozilla/5.0 (Windows NT 6.2) AppleWebKit/537.13 (KHTML, like Gecko) Chrome/24.0.1290.1 Safari/537.13' \
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.13 (KHTML, like Gecko) Chrome/24.0.1290.1 Safari/537.13' \
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_4) AppleWebKit/537.13 (KHTML, like Gecko) Chrome/24.0.1290.1 Safari/537.13' \
    'Mozilla/5.0 (Windows NT 6.2) AppleWebKit/536.3 (KHTML, like Gecko) Chrome/19.0.1061.1 Safari/536.3' \
    'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/536.3 (KHTML, like Gecko) Chrome/19.0.1061.1 Safari/536.3' \
    'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/536.3 (KHTML, like Gecko) Chrome/19.0.1061.1 Safari/536.3' \
    )
    echo ${USER_AGENTS[$RANDOM % ${#USER_AGENTS[@]} ]}
}

down() {
    USER_AGENT=$(user_agent)
    COOKIES_FILE=/tmp/oradown_COOKIES.txt
    rm -f ${COOKIES_FILE}

    # fetch osso_login.jsp page and retrieve form parameters
    form_data="$(curl -s -L -c ${COOKIES_FILE} -H "User-Agent: ${USER_AGENT}" ${URL})"

    declare -a form_fields=(
        'OAM_REQ'
        'request_id'
        'site2pstoretoken'
        'v'
    )

    declare data_string

    declare -i count
    for f in ${form_fields[@]}; do
        count=$((count+1))
        xpath="string(//form/input[@name='${f}']/@value)"
        data_string+="${f}=$(echo ${form_data} | xmllint --html --xpath ${xpath} 2>/dev/null -)"
        if [[ $count -lt ${#form_fields[@]} ]]; then
            data_string+='&'
        fi
    done

    # use filename from the URL (if explicit one not present)
    if [ -z "${OUTPUT_FILE}" ]; then
        OUTPUT_FILE=${URL##*/}
    fi

    # download file
    curl -L -o ${OUTPUT_FILE} -b ${COOKIES_FILE} -c ${COOKIES_FILE} 'https://login.oracle.com/oam/server/sso/auth_cred_submit' \
        -H "Cookie: s_cc=true; oraclelicense=${COOKIE_ACCEPT_LICENSE};" \
        -H "User-Agent: ${USER_AGENT}" \
        --data-urlencode "ssousername=${ORCL_USER}" \
        --data-urlencode "password=${ORCL_PWD}" \
        -d "${data_string}" \
        --compressed

    rm -f ${COOKIES_FILE}
}

# process arguments
while [ $# -gt 0 ]
do
    case "$1" in
        -C)
        COOKIE_ACCEPT_LICENSE="$2"
        if [ -z "${COOKIE_ACCEPT_LICENSE}" ]; then break; fi
        shift 2
        ;;
        --cookie=*)
        COOKIE_ACCEPT_LICENSE="${1#*=}"
        shift 1
        ;;
        -H | --help)
        usage 0
        ;;
        -O)
        OUTPUT_FILE="$2"
        if [ -z "${OUTPUT_FILE}" ]; then break; fi
        shift 2
        ;;
        --output=*)
        OUTPUT_FILE="${1#*=}"
        shift 1
        ;;
        -P)
        ORCL_PWD="$2"
        if [ -z "${ORCL_PWD}" ]; then break; fi
        shift 2
        ;;
        --password=*)
        ORCL_PWD="${1#*=}"
        shift 1
        ;;
        -U)
        ORCL_USER="$2"
        if [ -z "${ORCL_USER}" ]; then break; fi
        shift 2
        ;;
        --username=*)
        ORCL_USER="${1#*=}"
        shift 1
        ;;
        -V | --version)
        version
        ;;
        *)
        URL="$@"
        break
        ;;
    esac
done

if [ -z "${URL}" ]; then
    echoto 2 "Error: URL is mandatory.\n"
    usage 1
fi

if [ -z "${ORCL_USER}" ]; then
    echoto 2 "Error: USERNAME is mandatory.\n"
    usage 1
fi

if [ -z "${ORCL_PWD}" ]; then
    echoto 2 "Enter password for ${ORCL_USER}: "
    read -s ORCL_PWD
    echoto 2 "\n"
fi

if [ -z "${COOKIE_ACCEPT_LICENSE}" ]; then
    echoto 2 "Error: LICENSE_COOKIE is mandatory.\n"
    usage 1
fi

check_cmds_present
down
