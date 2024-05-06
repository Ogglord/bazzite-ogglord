## 1. BUILD ARGS
# These allow changing the produced image by passing different build args to adjust
# the source from which your image is built.
# Build args can be provided on the commandline when building locally with:
#   podman build -f Containerfile --build-arg FEDORA_VERSION=40 -t local-image

# SOURCE_IMAGE arg can be anything from ublue upstream which matches your desired version:
# See list here: https://github.com/orgs/ublue-os/packages?repo_name=main
# - "silverblue"
# - "kinoite"
# - "sericea"
# - "onyx"
# - "lazurite"
# - "vauxite"
# - "base"
# - "aurora"
# - "bazzite"
# - "bluefin"
# - "ucore"
ARG SOURCE_IMAGE="bazzite"
ARG SOURCE_SUFFIX=""
## SOURCE_TAG arg must be a version built for the specific image: eg, 39, 40, gts, latest
ARG SOURCE_TAG="testing"



### 2. SOURCE IMAGE
## this is a standard Containerfile FROM using the build ARGs above to select the right upstream image
FROM ghcr.io/ublue-os/${SOURCE_IMAGE}${SOURCE_SUFFIX}:${SOURCE_TAG}

ENV OS_VERSION=40
### 3. OG MODIFICATIONS
#############

# Clean up repos, everything is on the image so we don't need them
RUN  rm -f /etc/yum.repos.d/_copr*.repo && \
     rm -f /etc/yum.repos.d/charm.repo && \
     rm -f /etc/yum.repos.d/fedora-cisco-openh264.repo && \ 
     rm -f /etc/yum.repos.d/negativo17-fedora-multimedia.repo  && \ 
     rm -rf /tmp/* /var/* && \
     ostree container commit


## 3.I. Single installs
###########

# Some RPM install fails unless this directory exists
#RUN mkdir -p /var/lib/alternatives

## concatenate all .just files to 60-custom.just
COPY just /tmp/just
RUN find /tmp/just -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >> /usr/share/ublue-os/just/60-custom.just 

# Install yq to process yaml
RUN curl -Lo /tmp/yq.tar.gz "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64.tar.gz" && \
  tar -xzf /tmp/yq.tar.gz -C /tmp && \
  mv /tmp/yq_linux_amd64 /tmp/yq && \
  install -c -m 0755 /tmp/yq /usr/bin

# install Google Chrome
COPY scripts/install-google-chrome.sh /tmp/
RUN chmod +x /tmp/install-google-chrome.sh && \
    CHROME_RELEASE_CHANNEL=stable \  
    /tmp/install-google-chrome.sh

### Install 1password using blue-build 1password module
COPY --from=ghcr.io/blue-build/modules:latest /modules/bling/installers/1password.sh /tmp/1password.sh
RUN chmod +x /tmp/1password.sh && \
    ONEPASSWORD_RELEASE_CHANNEL=beta \
    GID_ONEPASSWORD=1500 \
    GID_ONEPASSWORDCLI=1600 \
        /tmp/1password.sh 

# Set up fonts using blue-build fonts module
COPY --from=ghcr.io/blue-build/modules:latest /modules/fonts /tmp/modules/fonts
COPY fonts.yml \
     scripts/fonts.sh \
        /tmp/
RUN chmod +x /tmp/fonts.sh && \
       /tmp/fonts.sh /tmp/fonts.yml && \
       ostree container commit


## 3.II Bulk installs
###########
COPY overlay/usr /usr
COPY overlay/etc/yum.repos.d/ /etc/yum.repos.d/

### Install packages using blue-build rpm-ostree module
#COPY --from=ghcr.io/blue-build/modules:latest /modules/rpm-ostree/rpm-ostree.sh /tmp/rpm-ostree.sh
COPY scripts/rpm-ostree.sh /tmp/
RUN chmod +x /tmp/rpm-ostree.sh && \
        /tmp/rpm-ostree.sh /tmp/apps.yml

# Set up services
RUN chmod +x /usr/bin/bazzite-og-user-vscode && \ 
    systemctl enable --global bazzite-og-user-vscode.service && \
    chmod +x /usr/bin/bazzite-og-user-bash && \ 
    systemctl enable --global bazzite-og-user-bash.service

# Clean up repos, everything is on the image so we don't need them
RUN  rm -f /etc/yum.repos.d/tailscale.repo && \
     rm -f /etc/yum.repos.d/vscode.repo && \
     rm -f /etc/yum.repos.d/docker-ce.repo && \
     rm -f /etc/yum.repos.d/atim-starship*.repo && \
     rm -rf /tmp/* /var/* && \
     ostree container commit