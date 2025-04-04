# Install common dependencies

# Install cmake 3.25+, needed by latest nextpnr and not provided by older
# distributions (debian 11, ubuntu 18.04 and 22.04)
# But not cmake 4 becuase it breaks the boolector build
CMAKE_VERSION=3.*
#CMAKE_VERSION=3.31.6-0kitware1ubuntu24.04.1
DEBIAN_FRONTEND=noninteractive apt update
apt install -y software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
apt install -y lsb-release wget gnupg
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor -o /usr/share/keyrings/kitware-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/kitware.list >/dev/null
DEBIAN_FRONTEND=noninteractive apt update
apt install -y cmake-data=$CMAKE_VERSION
apt install -y cmake=$CMAKE_VERSION

