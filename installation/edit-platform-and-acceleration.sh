# Updates the platform and the hardware-acceleration supported by an installation.

INSTALL_METHOD="${1}"

CURR_PLATFORM="${2}"
CURR_ACCELERATION="${3}"

NEW_PLATFORM="${4}"
NEW_ACCELERATION="${5}"

# Abort if variables not defined and show usage.
if [ -z "${INSTALL_METHOD}" ] || [ -z "${CURR_PLATFORM}" ] || [ -z "${CURR_ACCELERATION}" ]  || [ -z "${NEW_PLATFORM}" ] || [ -z "${NEW_ACCELERATION}" ]; then
  echo "Usage: installation/edit-platform-and-acceleration.sh INSTALL_METHOD CURR_PLATFORM CURR_ACCELERATION NEW_PLATFORM NEW_ACCELERATION"
  echo "Example: installation/edit-platform-and-acceleration.sh docker amd64 cuda arm64 cuda"
  echo "Example: installation/edit-platform-and-acceleration.sh docker amd64 cuda amd64 rocm"
  echo "Example: installation/edit-platform-and-acceleration.sh conda osx-arm64 mps linux-64 cuda"
  exit 1
fi

# Abort if the current installation does not exist.
if [ ! -d installation/"${INSTALL_METHOD}-${CURR_PLATFORM}-${CURR_ACCELERATION}" ]; then
  echo installation/"${INSTALL_METHOD}-${CURR_PLATFORM}-${CURR_ACCELERATION} does not exist."
  exit 1
fi

# Abort if the new installation already exists.
if [ -d  installation/"${INSTALL_METHOD}-${NEW_PLATFORM}-${NEW_ACCELERATION}" ]; then
  echo installation/"${INSTALL_METHOD}-${NEW_PLATFORM}-${NEW_ACCELERATION} already exists."
  exit 1
fi

# Rename the current to the new one.
mv installation/"${INSTALL_METHOD}-${CURR_PLATFORM}-${CURR_ACCELERATION}" installation/"${INSTALL_METHOD}-${NEW_PLATFORM}-${NEW_ACCELERATION}"

# Rename the installation combination in all the files.
for file in $(find "installation/${INSTALL_METHOD}-${NEW_PLATFORM}-${NEW_ACCELERATION}" -type f); do
  sed -i.deleteme "s/${INSTALL_METHOD}-${CURR_PLATFORM}-${CURR_ACCELERATION}/${INSTALL_METHOD}-${NEW_PLATFORM}-${NEW_ACCELERATION}/g" "${file}"
  rm "${file}.deleteme"
done

# Rename the default platform for the docker installation.
if [ "${INSTALL_METHOD}" = "docker" ]; then
  for file in $(find "installation/${INSTALL_METHOD}-${NEW_PLATFORM}-${NEW_ACCELERATION}" -type f -path "*/compose.yaml"); do
    sed -i.deleteme "s/${CURR_PLATFORM}/${NEW_PLATFORM}/g" "${file}"
    rm "${file}.deleteme"
  done
  if [ "${NEW_ACCELERATION}" != "cuda" ]; then
    cat "You have to edit the compose.yaml manually to add services that can leverage
     the ${NEW_ACCELERATION} acceleration for the local deployment option with Docker Compose.
     Refer to the dev-local-cuda service as an example for using NVIDIA GPUs."
  fi
fi
