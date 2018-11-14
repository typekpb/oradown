# to be set in CI
TEST_USERNAME=$ORA_LOGIN
TEST_PASSWORD=$ORA_PWD

TEST_LICENSE_COOKIE=accept-weblogicserver-cookie
TEST_URL=http://download.oracle.com/otn/nt/middleware/12c/12212/D-PCT-12212.zip

describe "-V, --version argument"
    it "-V argument exit status is 0"
        $SHPEC_ROOT/../oradown.sh -V >/dev/null 2>&1
        assert equal "$?" "0"
    end

    it "--version argument exit status is 0"
        $SHPEC_ROOT/../oradown.sh --version >/dev/null 2>&1
        assert equal "$?" "0"
    end

    it "-V prints 'oradown version: 0.0.4'"
        message="$($SHPEC_ROOT/../oradown.sh -V 2>&1)"
        assert grep "${message}" "oradown version: 0.0.4"
    end

    it "--version prints 'oradown version: 0.0.4'"
        message="$($SHPEC_ROOT/../oradown.sh --version 2>&1)"
        assert grep "${message}" "oradown version: 0.0.4"
    end
end

describe "-H, --help argument"
    it "-H argument exit status is 0"
        $SHPEC_ROOT/../oradown.sh -H >/dev/null 2>&1
        assert equal "$?" "0"
    end

    it "--help argument exit status is 0"
        $SHPEC_ROOT/../oradown.sh --help >/dev/null 2>&1
        assert equal "$?" "0"
    end
end

describe "-P, --password argument"
    it "-P|--password argument missing causes exits status 1"
        $SHPEC_ROOT/../oradown.sh --username=${TEST_USERNAME} --cookie=${TEST_LICENSE_COOKIE} ${TEST_URL} >/dev/null 2>&1
        assert equal "$?" "1"
    end

    it "-P|--password argument missing prints: 'Error: PASSWORD is mandatory'"
        message="$($SHPEC_ROOT/../oradown.sh --username=${TEST_USERNAME} --cookie=${TEST_LICENSE_COOKIE} ${TEST_URL} 2>&1)"
        assert grep "$message" "Error: PASSWORD is mandatory"
    end
end

describe "-U, --username argument"
    it "-U|--username argument missing causes exits status 1"
        $SHPEC_ROOT/../oradown.sh --password=${TEST_PASSWORD} --cookie=${TEST_LICENSE_COOKIE} ${TEST_URL} >/dev/null 2>&1
        assert equal "$?" "1"
    end

    it "-U|--username argument missing prints: 'Error: USERNAME is mandatory'"
        message="$($SHPEC_ROOT/../oradown.sh --password=${TEST_PASSWORD} --cookie=${TEST_LICENSE_COOKIE} ${TEST_URL} 2>&1)"
        assert grep "$message" "Error: USERNAME is mandatory"
    end
end

describe "C, --cookie argument"
    it "-C|--cookie argument missing causes exits status 1"
        $SHPEC_ROOT/../oradown.sh --username=${TEST_USERNAME} --password=${TEST_PASSWORD} ${TEST_URL} >/dev/null 2>&1
        assert equal "$?" "1"
    end

    it "-C|--cookie argument missing prints: 'Error: LICENSE_COOKIE is mandatory'"
        message="$($SHPEC_ROOT/../oradown.sh --username=${TEST_USERNAME} --password=${TEST_PASSWORD} ${TEST_URL} 2>&1)"
        assert grep "$message" "Error: LICENSE_COOKIE is mandatory"
    end
end

describe "URL"
    it "URL missing causes exits status 1"
        $SHPEC_ROOT/../oradown.sh --username=${TEST_USERNAME} --password=${TEST_PASSWORD} --cookie=${TEST_LICENSE_COOKIE} >/dev/null 2>&1
        assert equal "$?" "1"
    end

    it "URL missing prints: 'Error: URL is mandatory'"
        message="$($SHPEC_ROOT/../oradown.sh --username=${TEST_USERNAME} --password=${TEST_PASSWORD} --cookie=${TEST_LICENSE_COOKIE} 2>&1)"
        assert grep "$message" "Error: URL is mandatory"
    end
end

describe "OK input"
    it "OK input causes exits status 0"
        $SHPEC_ROOT/../oradown.sh --username=${TEST_USERNAME} --password=${TEST_PASSWORD} --cookie=${TEST_LICENSE_COOKIE} ${TEST_URL} >/dev/null 2>&1
        assert equal "$?" "0"
    end

    it "OK input downloads the specified file"
        $SHPEC_ROOT/../oradown.sh --username=${TEST_USERNAME} --password=${TEST_PASSWORD} --cookie=${TEST_LICENSE_COOKIE} ${TEST_URL} >/dev/null 2>&1
        assert valid_zip "./D-PCT-12212.zip"
        # cleanup
        rm -rf D-PCT-12212.zip
    end

    it "OK input with -O argument downloads to the specified file"
        $SHPEC_ROOT/../oradown.sh --username=${TEST_USERNAME} --password=${TEST_PASSWORD} --cookie=${TEST_LICENSE_COOKIE} -O /tmp/test.zip ${TEST_URL} >/dev/null 2>&1
        assert valid_zip "/tmp/test.zip"
        # cleanup
        rm -rf /tmp/test.zip
    end

    it "OK input with --output argument downloads to the specified file"
        $SHPEC_ROOT/../oradown.sh --username=${TEST_USERNAME} --password=${TEST_PASSWORD} --cookie=${TEST_LICENSE_COOKIE} --output=/tmp/test.zip ${TEST_URL} >/dev/null 2>&1
        assert valid_zip "/tmp/test.zip"
        # cleanup
        rm -rf /tmp/test.zip
    end
end
