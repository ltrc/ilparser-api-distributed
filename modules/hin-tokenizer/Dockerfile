FROM            ltrc/ilparser-dis-base
COPY            lib /hin-tokenizer/lib
COPY            api.pl /hin-tokenizer/
RUN             pip install /hin-tokenizer/lib/ilparser/hin/tokenizer/
ENTRYPOINT      /etc/init.d/postgresql start && \
                cd /hin-tokenizer && \
                hypnotoad -f api.pl
