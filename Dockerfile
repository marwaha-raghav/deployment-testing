# Pull official grafana image from Dockerhub

FROM grafana/grafana


# expose the port
EXPOSE 3000

ENTRYPOINT ["/run.sh"]


