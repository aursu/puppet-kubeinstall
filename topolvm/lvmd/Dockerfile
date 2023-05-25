ARG buildrepo=aursu/ubuntu
ARG os=focal-20230412

FROM ${buildrepo}:${os}-base

ENV tarfile_release=go1.20.4.linux-amd64.tar.gz
ENV tarfile_shasum=698ef3243972a51ddb4028e4a1ac63dc6d60821bf18e59a807e051fee0a385bd
ENV lvmd_version=0.19.0
ENV lvmd_tag=v${lvmd_version}

RUN echo "${tarfile_shasum}  ${tarfile_release}" > /${tarfile_release}.asc \
    && curl -sO https://dl.google.com/go/${tarfile_release} \
    && sha256sum -c ${tarfile_release}.asc \
    && tar -C /usr/local -xzf ${tarfile_release} \
    && echo export PATH=\"/usr/local/go/bin:\$PATH\" >> ~/.bashrc \
    && rm -f ${tarfile_release}*

RUN git clone https://github.com/topolvm/topolvm.git && cd topolvm/ \
    && git fetch origin ${lvmd_tag}:${lvmd_tag} && git checkout ${lvmd_tag} \
    && rm -rf .git

WORKDIR /topolvm

RUN mkdir sbin \
    && export PATH="/usr/local/go/bin:$PATH" \
    && go build -o sbin/lvmd ./pkg/lvmd \
    && rm -rf /root/go /root/.cache \
    && tar czf /lvmd-${lvmd_version}.tar.gz sbin

CMD /bin/bash