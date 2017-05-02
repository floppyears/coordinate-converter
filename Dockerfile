FROM golang:1.8.1

RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 16126D3A3E5C1192    \
    && apt-get update \
    && apt-get install -y --fix-missing --no-install-recommends \
            software-properties-common build-essential ca-certificates \
            git make cmake wget unzip libtool automake python-pip \
            libpython-dev libjpeg-dev zlib1g-dev \
            python-dev python-pip g++ doxygen dvipng \
            cmake zlib1g-dev texlive-latex-base \
            texlive-latex-extra git \
            graphviz python-matplotlib \
            python-setuptools imagemagick \
    && apt-get remove --purge -y $BUILD_PACKAGES  && rm -rf /var/lib/apt/lists/*


RUN mkdir /vdatum \
    && cd /vdatum \
    && wget http://download.osgeo.org/proj/vdatum/usa_geoid2012.zip && unzip -j -u usa_geoid2012.zip -d /usr/share/proj \
    && wget http://download.osgeo.org/proj/vdatum/usa_geoid2009.zip && unzip -j -u usa_geoid2009.zip -d /usr/share/proj \
    && wget http://download.osgeo.org/proj/vdatum/usa_geoid2003.zip && unzip -j -u usa_geoid2003.zip -d /usr/share/proj \
    && wget http://download.osgeo.org/proj/vdatum/usa_geoid1999.zip && unzip -j -u usa_geoid1999.zip -d /usr/share/proj \
    && wget http://download.osgeo.org/proj/vdatum/vertcon/vertconc.gtx && mv vertconc.gtx /usr/share/proj \
    && wget http://download.osgeo.org/proj/vdatum/vertcon/vertcone.gtx && mv vertcone.gtx /usr/share/proj \
    && wget http://download.osgeo.org/proj/vdatum/vertcon/vertconw.gtx && mv vertconw.gtx /usr/share/proj \
    && wget http://download.osgeo.org/proj/vdatum/egm96_15/egm96_15.gtx && mv egm96_15.gtx /usr/share/proj \
    && wget http://download.osgeo.org/proj/vdatum/egm08_25/egm08_25.gtx && mv egm08_25.gtx /usr/share/proj \
    && rm -rf /vdatum

RUN pip install Sphinx breathe \
    sphinx_bootstrap_theme awscli sphinxcontrib-bibtex \
    sphinx_rtd_theme

RUN git clone https://github.com/OSGeo/proj.4.git /proj.4 \
    && cd /proj.4 \
    && ./autogen.sh \
    && ./configure --prefix=/usr \
    && make \
    && make install \
    && cd /proj.4/docs \
    && make html \
    && rm -rf /proj.4

ADD . /go/src/github.com/osu-mist/coordinate-converter

WORKDIR /go/src/github.com/osu-mist/coordinate-converter

RUN go install

ENTRYPOINT /go/bin/coordinate-converter "$URL" "$FILEPATH"