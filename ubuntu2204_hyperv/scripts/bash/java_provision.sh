#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Installing Eclipse Temurin JDK 17 ..."

apt-get install -yq apt-transport-https gnupg && \
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list && \
    apt update -yq && apt install -yq temurin-17-jdk

java -version

-----------------------
#!/usr/bin/env bash
set -euo pipefail

# Argomenti ricevuti
enable_java="$1"
shift

# Ricostruzione: prima array versioni, poi array flavors
# NB: devi sapere quanti elementi appartengono a ciascun array.
# Qui assumiamo 2 versioni e 2 flavors come da esempio.
java_versions=("$1" "$2")
shift 2
java_flavors=("$1" "$2")

if [[ "$enable_java" != "true" ]]; then
  echo "[INFO] Java install disabled, exiting."
  exit 0
fi

echo "[INFO] Installing SDKMAN..."
sudo apt-get update -qq
sudo apt-get install -y curl zip unzip
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"

echo "[INFO] Installing Java versions/flavors..."
for version in "${java_versions[@]}"; do
  for flavor in "${java_flavors[@]}"; do
    candidate="${version}-${flavor}"
    echo "[INFO] Installing $candidate via SDKMAN..."
    sdk install java "$candidate"
  done
done

apt install -y build-essential zlib1g-dev libssl-dev libffi-dev pkg-config
apt install autoconf automake libtool m4




