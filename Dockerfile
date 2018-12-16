FROM dm848/cs-jolie:v1

WORKDIR /service
COPY . /service

# add ContainerPilot configuration
RUN mv service.json5 /etc/containerpilot.json5
ENV CONTAINERPILOT=/etc/containerpilot.json5

# expose http port
EXPOSE {{ service.port }}:{{ service.port }}
CMD ["/bin/containerpilot"]
