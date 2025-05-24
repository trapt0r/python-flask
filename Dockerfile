FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_TOOL_CACHE=/opt/hostedtoolcache
ENV PATH=$PATH:/usr/local/bin

# Core tools: jq, yq, gh, oc, Sonatype IQ CLI
RUN apt-get update && apt-get install -y \
    curl unzip tar xz-utils jq git ca-certificates gnupg software-properties-common && \
    curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq && \
    mkdir -p -m 0755 /etc/apt/keyrings && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /etc/apt/keyrings/githubcli.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && apt-get install -y gh && \
    curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz | tar -xz -C /usr/local/bin && \
    curl -L https://sonatype-download.global.ssl.fastly.net/repository/downloads-prod-group/scanner/nexus-iq-cli-2.4.2-01+965-unix.zip -o iqcli.zip && \
    unzip iqcli.zip -d /usr/local/bin/iqcli && \
    chmod +x /usr/local/bin/iqcli/nexus-iq-cli && \
    ln -s /usr/local/bin/iqcli/nexus-iq-cli /usr/local/bin/iq && \
    rm iqcli.zip && \
    rm -rf /var/lib/apt/lists/*

# Install GitHub Actions runner manually
RUN mkdir -p /actions-runner && cd /actions-runner && \
    curl -O -L https://github.com/actions/runner/releases/download/v2.316.0/actions-runner-linux-x64-2.316.0.tar.gz && \
    tar xzf ./actions-runner-linux-x64-2.316.0.tar.gz && \
    ./bin/installdependencies.sh && \
    rm actions-runner-linux-x64-2.316.0.tar.gz

# Maven
RUN curl -fsSL https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz | \
    tar -xz -C /opt && \
    ln -s /opt/apache-maven-3.9.9/bin/mvn /usr/local/bin/mvn

# Java (Temurin + Microsoft)
RUN bash -c '\
  mkdir -p ${RUNNER_TOOL_CACHE}/Java && cd ${RUNNER_TOOL_CACHE}/Java && \
  declare -A urls=( \
    [Temurin_8]="https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u412-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u412b08.tar.gz" \
    [Temurin_11]="https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.22+7/OpenJDK11U-jdk_x64_linux_hotspot_11.0.22_7.tar.gz" \
    [Temurin_17]="https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.10+7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.10_7.tar.gz" \
    [Temurin_21]="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2+13/OpenJDK21U-jdk_x64_linux_hotspot_21.0.2_13.tar.gz" \
    [Microsoft_11]="https://aka.ms/download-jdk/microsoft-jdk-11.0.21-linux-x64.tar.gz" \
    [Microsoft_17]="https://aka.ms/download-jdk/microsoft-jdk-17.0.9-linux-x64.tar.gz" \
    [Microsoft_21]="https://aka.ms/download-jdk/microsoft-jdk-21.0.1-linux-x64.tar.gz" \
  ); \
  for vendor in Temurin Microsoft; do \
    for version in 8 11 17 21; do \
      [[ "$vendor" == "Microsoft" && "$version" == "8" ]] && continue; \
      dir="${vendor}_jdk/${version}/x64"; \
      url="${urls[${vendor}_${version}]}"; \
      echo "Installing ${vendor} JDK ${version} from ${url}"; \
      mkdir -p "$dir"; \
      curl -fsSL "$url" | tar -xz -C "$dir" --strip-components=1 && \
      echo "$version" > "$dir.complete"; \
    done; \
  done'

# Node.js (20, 21, 22)
RUN for version in 20.12.2 21.7.3 22.2.0; do \
    major=$(echo $version | cut -d. -f1); \
    mkdir -p ${RUNNER_TOOL_CACHE}/Node/${major}.x && \
    curl -L "https://nodejs.org/dist/v$version/node-v$version-linux-x64.tar.xz" | \
    tar -xJ --strip-components=1 -C ${RUNNER_TOOL_CACHE}/Node/${major}.x && \
    echo "$version" > ${RUNNER_TOOL_CACHE}/Node/${major}.x.complete; \
  done

# Python (3.10, 3.11, 3.12)
RUN apt-get update && apt-get install -y make build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
    libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev && \
  for version in 3.10.14 3.11.9 3.12.3; do \
    curl -LO "https://www.python.org/ftp/python/${version}/Python-${version}.tgz" && \
    tar -xzf Python-${version}.tgz && \
    cd Python-${version} && \
    ./configure --prefix=${RUNNER_TOOL_CACHE}/Python/${version}/x64 && \
    make -j$(nproc) && make install && \
    echo "$version" > ${RUNNER_TOOL_CACHE}/Python/${version}/x64.complete && \
    cd .. && rm -rf Python-${version}*; \
  done && \
  apt-get purge -y make build-essential && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

