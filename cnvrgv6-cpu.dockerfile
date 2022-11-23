# !/usr/bin/env bash
FROM ubuntu:22.04

### Export env settings
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL=C

### Install essential apps and Python3
ENV TZ=America/New_York
RUN DEBIAN_FRONTEND=noninteractive  apt-get update -y --no-install-recommends && apt-get install build-essential -y --no-install-recommends && \
    apt-get install -y --no-install-recommends software-properties-common
RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y screen nload htop curl wget curl vim iputils-ping git nano sudo gnupg apt-transport-https \
    libsm6 libxext6 libxrender-dev libltdl7 zip
RUN apt-get install -y python3 python3-dev python3-pip
RUN pip3 install --upgrade pip

### Install kubectl + add kc aliases
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x ./kubectl
RUN sudo mv ./kubectl /usr/local/bin/kubectl
RUN echo 'alias kc="kubectl -n cnvrg"' >> ~/.bashrc
RUN echo 'alias app="kubectl -n cnvrg exec -it deploy/app -- bash -l"' >> ~/.bashrc
RUN echo 'alias cnvrg-app="kubectl -n cnvrg exec -it deploy/cnvrg-app -- bash -l"' >> ~/.bashrc
RUN echo 'alias app-v="kc get pods -l app=app -o jsonpath='{.items[0].spec.containers[0].image}'; echo"' >> ~/.bashrc
RUN echo 'alias kwatch="watch 'kubectl -n cnvrg get pods'"' >> ~/.bashrc

### Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN sudo ./aws/install

## Install Minio CLI
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc
RUN chmod +x mc && ./mc --help && ./mc ls && ls -la /root/.mc/config.json

## Install HELM
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

### Install Python Packages
RUN pip3 install scipy numpy pandas tensorflow scikit-learn opencv-python keras dash dash-daq voila xgboost sklearn

##Create ds USER
RUN useradd --create-home --home-dir /home/ds --shell /bin/bash ds && adduser ds sudo

    ### Make sure python paths are set ###
RUN ln -ns /usr/bin/python3 /usr/bin/python

### Install flask server for endpoints
RUN pip3 install gunicorn
RUN pip3 install flask flask-restful requests flask_sqlalchemy --no-cache
RUN pip3 install flask_jsonpify pydevd-pycharm snowflake-connector-python google-api-python-client


### Install nodejs and npm for JupyterLab
RUN curl -sL https://deb.nodesource.com/setup_14.x  | bash -
RUN apt-get -y install nodejs
RUN npm install npm -g

### Install JupyterLab
RUN pip3 install --upgrade jupyterlab
RUN pip3 install --upgrade jupyterlab-git && jupyter lab build

RUN jupyter labextension install @jupyterlab/git && \
    jupyter server extension enable --py jupyterlab_git --sys-prefix && \
    jupyter lab build

RUN apt-get update && apt-get install -y libsasl2-dev
RUN pip3 install setuptools wheel pyarrow
RUN pip3 install --upgrade cnvrg pip catboost nltk
RUN apt-get update && apt-get install -y libxslt-dev libxml2-dev zlib1g-dev 
RUN apt-get update

RUN pip3 uninstall -y snowflake-connector-python
RUN pip3 install jedi==0.18.1 #for ipython compatibility

RUN apt-get install -y shared-mime-info bzip2 ca-certificates libglib2.0-0 libxrender1

### Install cnvrg sdk and cli ###
RUN pip install --upgrade cnvrgv2
#RUN gem install cnvrg --no-document


RUN pip3 install --upgrade cnvrg
RUN apt-get update && apt-get install -y openssh-server && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
ENV SHELL=/bin/bash
ENV HOME=/root
