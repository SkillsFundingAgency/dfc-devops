#Developed from https://github.com/justb4/docker-jmeter/blob/master/Dockerfile (commit 6aa034c6c362f8e29cb81f7d51637560d29b2f24)
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

ARG JMETER_VERSION="5.1.1"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

RUN apt-get update 
RUN apt-get install --no-install-recommends \
    ca-certificates \
    default-jre \
    tzdata \
    curl \
    unzip \
    bash \
    libnss3
RUN rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt  \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
	&& rm -rf /tmp/dependencies

# TODO: plugins (later)
# && unzip -oq "/tmp/dependencies/JMeterPlugins-*.zip" -d $JMETER_HOME

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN

# Install dependencies for Azure DevOps agent
RUN apt-get update 
# Required to install libicu55 on Ubuntu versions > 16.04, the base image of owasp/zap2docker-stable at the time of writing is later than 16.04
RUN apt-get install software-properties-common
RUN add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"

RUN apt-get install --no-install-recommends \
    ca-certificates \
    jq \
    git \
    iputils-ping \
    libcurl3 \
    libicu55 \
    libunwind8 \
    netcat
# curl install returns broken package error if installed alongside other packages
RUN apt-get install --no-install-recommends curl
# Finished installing dependencies for Azure DevOps agent

# install PowerShell
RUN apt-get install wget
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update
RUN add-apt-repository universe
RUN apt-get install -y powershell

#Reference: https://www.gnu.org/software/libc/manual/html_node/TZ-Variable.html
ENV TZ="Europe/London"

WORKDIR /agent-init.d
COPY JMeterScripts/startup.sh .

WORKDIR /scripts
COPY AgentScripts/convert-report.ps1 .
COPY JMeterScripts/jmeter-to-junit.xlst .

WORKDIR /azp
COPY AgentScripts/install-agent.sh .
RUN chmod +x install-agent.sh

CMD ["./install-agent.sh"]

