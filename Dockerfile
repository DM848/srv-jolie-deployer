FROM dm848/cs-jolie-kubectl:v1.0.1

WORKDIR /service
COPY . /service
RUN chmod +x get_cpu.sh
RUN chmod +x get_memory.sh

# add ContainerPilot configuration
RUN mv service.json5 /etc/containerpilot.json5
ENV CONTAINERPILOT=/etc/containerpilot.json5

# expose http port
EXPOSE 8000:8000
CMD ["/bin/containerpilot"]
