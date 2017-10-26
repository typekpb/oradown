valid_zip() {
  unzip -t "$1" > /dev/null 2>&1
  assert equal "$?" 0
}
