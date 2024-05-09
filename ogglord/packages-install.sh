#!/bin/sh

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

if [[ -z ${PACKAGE_LIST} ]];then
   echo "Error in packages.sh: variable PACKAGE_LIST is not set!"
   exit 2
fi

if [[ -z ${OS_VERSION} ]];then
   echo "Error in packages.sh: variable OS_VERSION is not set!"
   exit 3
fi

# build list of all packages requested for inclusion
INCLUDED_PACKAGES=($(jq -r "[(.all.include | (.all, select(.\"$PACKAGE_LIST\" != null).\"$PACKAGE_LIST\")[]), \
                             (select(.\"$OS_VERSION\" != null).\"$OS_VERSION\".include | (.all, select(.\"$PACKAGE_LIST\" != null).\"$PACKAGE_LIST\")[])] \
                             | sort | unique[]" /tmp/packages.json))

# build list of all packages requested for exclusion
EXCLUDED_PACKAGES=($(jq -r "[(.all.exclude | (.all, select(.\"$PACKAGE_LIST\" != null).\"$PACKAGE_LIST\")[]), \
                             (select(.\"$OS_VERSION\" != null).\"$OS_VERSION\".exclude | (.all, select(.\"$PACKAGE_LIST\" != null).\"$PACKAGE_LIST\")[])] \
                             | sort | unique[]" /tmp/packages.json))


# ensure exclusion list only contains packages already present on image
if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    EXCLUDED_PACKAGES=($(rpm -qa --queryformat='%{NAME} ' ${EXCLUDED_PACKAGES[@]}))
fi

# ensure exclusion list only contains packages already present on image
if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    EXCLUDED_PACKAGES=($(rpm -qa --queryformat='%{NAME} ' ${EXCLUDED_PACKAGES[@]}))
fi

# simple case to install where no packages need excluding
if [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 && "${#EXCLUDED_PACKAGES[@]}" -eq 0 ]]; then
    echo "Installing: ${INCLUDED_PACKAGES[@]}"
    rpm-ostree install ${INCLUDED_PACKAGES[@]}

# install/excluded packages both at same time
elif [[ "${#INCLUDED_PACKAGES[@]}" -gt 0 && "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    rpm-ostree override remove \
        ${EXCLUDED_PACKAGES[@]} \
        $(printf -- "--install=%s " ${INCLUDED_PACKAGES[@]})

else
    echo "No packages to install."

fi

# check if any excluded packages are still present
# (this can happen if an included package pulls in a dependency)
EXCLUDED_PACKAGES=($(jq -r "[(.all.exclude | (.all, select(.\"$PACKAGE_LIST\" != null).\"$PACKAGE_LIST\")[]), \
                             (select(.\"$OS_VERSION\" != null).\"$OS_VERSION\".exclude | (.all, select(.\"$PACKAGE_LIST\" != null).\"$PACKAGE_LIST\")[])] \
                             | sort | unique[]" /tmp/packages.json))

if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    EXCLUDED_PACKAGES=($(rpm -qa --queryformat='%{NAME} ' ${EXCLUDED_PACKAGES[@]}))
fi

# remove any excluded packages which are still present on image
if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    rpm-ostree override remove \
        ${EXCLUDED_PACKAGES[@]}
fi
