FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

# docker build -t aibox .

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ARG DEBIAN_FRONTEND=noninteractive

# Install tini
ENV TINI_VERSION v0.14.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN apt update
RUN apt-get install -fy curl sudo unzip wget curl sudo git-core  && sudo apt -y autoremove

ENV PATH=/opt/conda/bin:${PATH}

## Conda:
RUN wget https://repo.continuum.io/archive/Anaconda3-2018.12-Linux-x86_64.sh -O /tmp/anaconda.sh && bash /tmp/anaconda.sh -b -p /opt/conda && rm /tmp/anaconda.sh

## Base:
RUN conda install pandas

## Sklearn
RUN conda install scikit-learn 

## FastAI + dependencies:
RUN apt-get install -fy qtdeclarative5-dev qml-module-qtquick-controls
RUN conda uninstall --force jpeg libtiff -y
RUN conda install -c conda-forge libjpeg-turbo
RUN conda install -c pytorch -c fastai fastai
RUN ldconfig #workaround issue with cuda

## Spacey:
RUN python -m spacy download en

## API:
RUN conda install flask

# IPython
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"
RUN groupadd wheel -g 11 && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER
RUN mkdir /home/$NB_USER/work && \
    mkdir /home/$NB_USER/.torch/ && \
    chown 1000:100 -R /home/$NB_USER && \
    chown 1000:100 -R /opt/conda

#LDCONFIG
RUN ldconfig && ldconfig /usr/local/cuda-9.0/targets/x86_64-linux/lib/stubs

USER $NB_UID
RUN jupyter notebook --generate-config
RUN echo "c.NotebookApp.ip = '*'" >> ~/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.open_browser = False" >> ~/.jupyter/jupyter_notebook_config.py
RUN jupyter nbextension enable --py widgetsnbextension --sys-prefix

EXPOSE 8888

#################################################################################################################
#           START UP
#################################################################################################################

VOLUME /home/$NB_USER/work
WORKDIR /home/$NB_USER/work

ENTRYPOINT [ "/tini", "-g", "--" ]
COPY ./start.sh /tmp/start.sh

USER root
ENV NB_USER ${NB_USER}
CMD bash /tmp/start.sh ${NB_USER}
