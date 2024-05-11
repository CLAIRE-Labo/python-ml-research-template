# Updates the platform and the hardware-acceleration supported by an installation.

CHANGE_OR_COPY="${1}"
INSTALL_METHOD="${2}"

CURR_PLATFORM="${3}"
CURR_ACCELERATION="${4}"

NEW_PLATFORM="${5}"
NEW_ACCELERATION="${6}"

# Abort if variables not defined and show usage.
if [ -z "${CHANGE_OR_COPY}" ] || [ -z "${INSTALL_METHOD}" ] || [ -z "${CURR_PLATFORM}" ] || [ -z "${CURR_ACCELERATION}" ]  || [ -z "${NEW_PLATFORM}" ] || [ -z "${NEW_ACCELERATION}" ]; then
  echo "Usage: installation/edit-platform-and-acceleration.sh CHANGE_OR_COPY CURR_PLATFORM CURR_ACCELERATION NEW_PLATFORM NEW_ACCELERATION"
  echo "Example: installation/edit-platform-and-acceleration.sh change docker amd64 cuda arm64 cuda"
  echo "Example: installation/edit-platform-and-acceleration.sh copy docker amd64 cuda arm64 cuda"
  echo "Example: installation/edit-platform-and-acceleration.sh change docker amd64 cuda amd64 rocm"
  echo "Example: installation/edit-platform-and-acceleration.sh change conda osx-arm64 mps linux-64 cuda"
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

if [ "${CHANGE_OR_COPY}" = "change" ]; then
  mv installation/"${INSTALL_METHOD}-${CURR_PLATFORM}-${CURR_ACCELERATION}" installation/"${INSTALL_METHOD}-${NEW_PLATFORM}-${NEW_ACCELERATION}"
elif [ "${CHANGE_OR_COPY}" = "copy" ]; then
  cp -r installation/"${INSTALL_METHOD}-${CURR_PLATFORM}-${CURR_ACCELERATION}" installation/"${INSTALL_METHOD}-${NEW_PLATFORM}-${NEW_ACCELERATION}"
else
  echo "CHANGE_OR_COPY must be either change or copy."
  exit 1
fi

# Rename the installation combination in all the files.
for file in $(find "installation/${INSTALL_METHOD}-${NEW_PLATFORM}-${NEW_ACCELERATION}" -type f); do
  sed -i.deleteme "s/${CURR_PLATFORM}-${CURR_ACCELERATION}/${NEW_PLATFORM}-${NEW_ACCELERATION}/g" "${file}"
  sed -i.deleteme "s/${CURR_PLATFORM}/${NEW_PLATFORM}/g" "${file}"
  rm "${file}.deleteme"
done

# Rename the default platform for the docker installation.
if [ "${INSTALL_METHOD}" = "docker" ]; then
  if [ "${NEW_ACCELERATION}" != "cuda" ]; then
    echo "You have to edit the compose.yaml manually to add services that can leverage
     the ${NEW_ACCELERATION} acceleration for the local deployment option with Docker Compose.
     Refer to the dev-local-cuda service as an example for using NVIDIA GPUs."
  fi
fi
