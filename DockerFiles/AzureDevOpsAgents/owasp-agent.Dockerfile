FROM owasp/zap2docker-stable:latest

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

# Install dependencies for Azure DevOps agent
RUN apt-get update 
# Required to install libicu55 on Ubuntu versions > 16.04, the base image of owasp/zap2docker-stable at the time of writing is later than 16.04
RUN apt-get install software-properties-common
RUN add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main"

RUN apt-get install -y --no-install-recommends \
    ca-certificates \
    jq \
    git \
    iputils-ping \
    libcurl3 \
    libicu55 \
    libunwind8 \
    netcat
# curl install returns broken package error if installed alongside other packages
RUN apt-get install -y --no-install-recommends curl
# Finished installing dependencies for Azure DevOps agent

# install PowerShell
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update
RUN add-apt-repository universe
RUN apt-get install -y powershell

RUN mkdir /zap/output
RUN mkdir /zap/wrk
WORKDIR /zap/wrk
COPY AgentScripts/convert-report.ps1 .
COPY OwaspScripts/owasp-to-nunit3.xlst .
RUN chmod +x convert-report.ps1

WORKDIR /azp

COPY AgentScripts/install-agent.sh .
RUN chmod +x install-agent.sh

CMD ["./install-agent.sh"]