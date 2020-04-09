#Developed from https://github.com/justb4/docker-jmeter/blob/master/Dockerfile (commit 6aa034c6c362f8e29cb81f7d51637560d29b2f24)
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

ARG JMETER_VERSION="5.2.1"
ARG NEO4J_PLUGIN_VERSION="4.0.0"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV	JMETER_BIN	${JMETER_HOME}/bin
ENV	JMETER_DOWNLOAD_URL  https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
ENV JVM_ARGS "-Xms1g -Xmx3g -XX:MaxMetaspaceSize=768m"

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

# Install Plugin Manager
RUN mkdir -p /tmp/dependencies \
    && curl -L --silent https://jmeter-plugins.org/get/ > $JMETER_HOME/lib/ext/jmeter-plugins-manager.jar \
    && java -cp $JMETER_HOME/lib/ext/jmeter-plugins-manager.jar org.jmeterplugins.repository.PluginManagerCMDInstaller \
    && curl -L --silent http://search.maven.org/remotecontent?filepath=kg/apc/cmdrunner/2.2/cmdrunner-2.2.jar > $JMETER_HOME/lib/cmdrunner-2.2.jar \
    && rm -rf /tmp/dependencies

# Install additional plugins using Plugin Manager
RUN $JMETER_BIN/PluginsManagerCMD.sh install jpgc-filterresults=2.2,jpgc-graphs-basic=2.0,jpgc-graphs-additional=2.0,jpgc-graphs-dist=2.0,jpgc-ggl=2.0,jpgc-synthesis=2.2,jpgc-casutg=2.9

# Install Neo4j driver
RUN mkdir -p /tmp/dependencies \
    && curl -L --silent https://github.com/neo4j/neo4j-java-driver/archive/${NEO4J_PLUGIN_VERSION}.tar.gz > /tmp/dependencies/neo4j-pluggin-${NEO4J_PLUGIN_VERSION}.tar.gz \
    && tar -xzf /tmp/dependencies/neo4j-pluggin-${NEO4J_PLUGIN_VERSION}.tar.gz -C $JMETER_HOME/lib/ext \
    && rm -rf /tmp/dependencies


# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN

#Reference: https://www.gnu.org/software/libc/manual/html_node/TZ-Variable.html
ENV TZ="Europe/London"

##TO DO: change script loc WORKDIR /agent-init.d
COPY JMeterScripts/startup.sh .

ENTRYPOINT $JMETER_HOME/bin/jmeter-server \
-Dserver.rmi.localport=50000 \
-Dserver_port=1099 \
-Jserver.rmi.ssl.disable=true