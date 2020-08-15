#!/usr/bin/env bash

set -Eeu

# https://stackoverflow.com/a/246128
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "#!/usr/bin/env bash"
echo "# Compiled basis config.d"
echo
echo " ("
echo "set -Eeu"
#shellcheck disable=SC2028
echo "trap 'printf \"***\n*** Failed to run basis config.d ***\n***\n\"' ERR"
echo

while IFS= read -r -d $'\0' file; do
  echo "###"
  echo "### $(basename "$file")"
  echo "###"
  echo "("
  echo "echo '### Running $(basename "$file")'"
  cat "$file"
  echo ")"
  echo
done < <(find "$DIR"/config.d -name '*.sh' -print0 | sort -z)

echo "echo; echo 'Finished running basis config.d'; echo"
echo ")"
