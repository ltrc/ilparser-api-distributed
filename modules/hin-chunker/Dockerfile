FROM            ltrc/ilparser-dis-base
COPY            lib /hin-chunker/lib
COPY            api.pl /hin-chunker/
RUN             curl -L https://github.com/ltrc/ilparser-api/releases/download/0.1/CRF.-0.58.tar.gz | tar -xz \
                    && cd CRF++-0.58 && ./configure && make install \
                    && echo "/usr/local" > /etc/ld.so.conf.d/crfpp.conf && ldconfig \
                    && cd -
ENTRYPOINT      /etc/init.d/postgresql start && \
                cd /hin-chunker && \
                hypnotoad -f api.pl
