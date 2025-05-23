FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_TOOL_CACHE=/opt/hostedtoolcache
ENV PATH=$PATH:/usr/local/bin

# System prep
RUN apt-get update && apt-get install -y \
  curl wget unzip tar git jq xz-utils build-essential \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
  software-properties-common libffi-dev lsb-release ca-certificates gnupg \
  python3-pip && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p ${RUNNER_TOOL_CACHE}

# Install yq
RUN curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  -o /usr/local/bin/yq && chmod +x /usr/local/bin/yq

# Install gh CLI
RUN mkdir -p -m 0755 /etc/apt/keyrings && \
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  gpg --dearmor -o /etc/apt/keyrings/githubcli.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli.gpg] https://cli.github.com/packages stable main" \
  | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
  apt-get update && apt-get install -y gh && rm -rf /var/lib/apt/lists/*

# Install oc CLI
RUN curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz \
  | tar -xz -C /usr/local/bin

RUN curl -L https://sonatype-download.global.ssl.fastly.net/repository/downloads-prod-group/scanner/nexus-iq-cli-2.4.2-01+965-unix.zip -o iqcli.zip && \
    unzip iqcli.zip -d /usr/local/bin/iqcli && \
    chmod +x /usr/local/bin/iqcli/nexus-iq-cli && \
    ln -s /usr/local/bin/iqcli/nexus-iq-cli /usr/local/bin/iq && \
    rm iqcli.zip


# Install Maven 3.9.9
RUN mkdir -p /opt/maven && \
  curl -fsSL https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz \
  | tar -xz -C /opt/maven && \
  ln -s /opt/maven/apache-maven-3.9.9/bin/mvn /usr/local/bin/mvn

# --- Install Java Versions ---
RUN bash -c '\
  mkdir -p ${RUNNER_TOOL_CACHE}/Java && cd ${RUNNER_TOOL_CACHE}/Java && \
  declare -A urls=( \
    [Microsoft_11]="https://aka.ms/download-jdk/microsoft-jdk-11.0.21-linux-x64.tar.gz" \
    [Microsoft_17]="https://aka.ms/download-jdk/microsoft-jdk-17.0.9-linux-x64.tar.gz" \
    [Microsoft_21]="https://aka.ms/download-jdk/microsoft-jdk-21.0.1-linux-x64.tar.gz" \
    [Amazon_11]="https://corretto.aws/downloads/latest/amazon-corretto-11-x64-linux-jdk.tar.gz" \
    [Amazon_17]="https://corretto.aws/downloads/latest/amazon-corretto-17-x64-linux-jdk.tar.gz" \
    [Amazon_21]="https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.tar.gz" \
    [Temurin_11]="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.22+7/OpenJDK11U-jdk_x64_linux_hotspot_11.0.22_7.tar.gz" \
    [Temurin_17]="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10+7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.10_7.tar.gz" \
    [Temurin_21]="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2+13/OpenJDK21U-jdk_x64_linux_hotspot_21.0.2_13.tar.gz" \
  ); \
  for vendor in Microsoft Amazon Temurin; do \
    for version in 11 17 21; do \
      dir="${vendor}_jdk/${version}/x64"; \
      url="${urls[${vendor}_${version}]}"; \
      echo "Downloading ${vendor} JDK ${version} from ${url}..."; \
      mkdir -p "$dir"; \
      curl -fsSL "$url" | tar -xz -C "$dir" --strip-components=1 && \
      echo "$version" > "$dir.complete"; \
    done; \
  done'




# --- Install Python Versions ---
RUN for version in 3.10.14 3.11.9 3.12.3; do \
  curl -LO "https://www.python.org/ftp/python/${version}/Python-${version}.tgz" && \
  tar -xzf Python-${version}.tgz && \
  cd Python-${version} && \
  ./configure --prefix=${RUNNER_TOOL_CACHE}/Python/${version}/x64 && \
  make -j$(nproc) && make install && \
  echo "${version}" > ${RUNNER_TOOL_CACHE}/Python/${version}/x64.complete && \
  cd .. && rm -rf Python-${version}*; \
done


# --- Install Node.js Versions ---
RUN for version in 20.12.2 21.7.3 22.2.0; do \
    major=$(echo $version | cut -d. -f1); \
    mkdir -p ${RUNNER_TOOL_CACHE}/Node/${major}.x && \
    curl -L "https://nodejs.org/dist/v${version}/node-v${version}-linux-x64.tar.xz" \
    | tar -xJ --strip-components=1 -C ${RUNNER_TOOL_CACHE}/Node/${major}.x && \
    echo "$version" > ${RUNNER_TOOL_CACHE}/Node/${major}.x.complete; \
  done

# Default entrypoint (you will likely override this via your ephemeral runner script)
CMD ["/bin/bash"]

