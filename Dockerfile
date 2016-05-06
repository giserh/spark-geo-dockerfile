# use Ubuntu 16.04 LTS as the base
FROM ubuntu:16.04
MAINTAINER Joel McCune <jmccune@esri.com>

# refresh and get all updates
RUN apt-get update && apt-get -y upgrade

# install software already in repos
RUN apt-get update && apt-get install -y \
	elasticsearch \ 
	git \
	maven \
	software-properties-common \  # so we can add the Oracle Java repo
	wget

# add the Oracle Java repo
RUN apt-add-repository -y ppa:webupd8team/java

# make sure we do not have to manually accept the licenses for Java
RUN echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
	&& echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

# install java
RUN apt-get update && apt-get -y install oracle-java8-installer

# download and set up Spark
RUN wget http://mirror.cogentco.com/pub/apache/spark/spark-1.6.1/spark-1.6.1-bin-hadoop2.6.tgz
RUN tar xvf ./spark-1.6.1-bin-hadoop2.6.tgz
RUN mv ./spark-1.6.1-bin-hadoop2.6 /opt && ln -s /opt/spark-1.6.1-bin-hadoop2.6 /opt/spark

# add these lines to the ~/.bash_profile so spark can be accessed directly from the command line
RUN echo 'SPARK_HOME=/opt/spark' >> ~/.bash_profile && echo 'PATH=$PATH:$SPARK_HOME/bin' >> ~/.bash

# get and install Mansour's custom code dependencies; then get and install spark-csv-es
RUN mkdir ~/install && cd ~/install
RUN git clone https://github.com/mraad/WebMercator && cd ./WebMercator && mvn install && cd ../
RUN git clone https://github.com/mraad/hex-grid && cd ./hex-grid && mvn install && cd ../
RUN git clone https://github.com/mraad/spark-csv-es && cd ./spark-csv-es && mvn install && cd ../

# remove all the downloaded and extracted assets
RUN rm -rf ~/install

# install elasticsearch plugin dependencies
RUN /usr/share/elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf/master
RUN /usr/share/elasticsearch/bin/plugin install https://github.com/NLPchina/elasticsearch-sql/releases/download/2.3.2.0/elasticsearch-sql-2.3.2.0.zip

# expose elasticsearch port
EXPOSE 9200
