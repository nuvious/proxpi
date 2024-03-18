FROM python:3.12-alpine

# RUN --mount=source=.,target=/root/src/proxpi,rw \
#     uname -a && cat /etc/issue && apk --version && python --version && pip --version \
#  && apk --no-cache add git build-base libxslt-dev libxml2-dev \
#  && git -C /root/src/proxpi restore .dockerignore \
#  && pip install --no-cache-dir --no-deps \
#     --requirement /root/src/proxpi/app.requirements.txt \
#  && pip install --no-cache-dir --no-deps /root/src/proxpi/ \
#  && pip show gunicorn \
#  && apk del --purge git build-base libxslt-dev libxml2-dev \
#  && pip list

# Doing this just to more easily see what's failing.
COPY . /root/src/proxpi
RUN uname -a
RUN cat /etc/issue
RUN apk --version
RUN python --version
RUN pip --version
RUN apk --no-cache add git build-base libxslt-dev libxml2-dev
RUN git -C /root/src/proxpi restore .dockerignore
RUN pip install --no-cache-dir --no-deps \
    --requirement /root/src/proxpi/app.requirements.txt
RUN pip install --no-cache-dir --no-deps /root/src/proxpi/
RUN pip show gunicorn
RUN apk del --purge git build-base libxslt-dev libxml2-dev
RUN pip list


ENTRYPOINT [ \
    "gunicorn", \
    "--preload", \
    "--access-logfile", "-", \
    "--access-logformat", "%(h)s \"%(r)s\" %(s)s %(b)s %(M)dms", \
    "--logger-class", "proxpi.server._GunicornLogger", \
    "proxpi.server:app" \
]
CMD ["--bind", "0.0.0.0:5000", "--threads", "2"]
