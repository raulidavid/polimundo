FROM mysql:latest

ARG AMBIENTE=${AMBIENTE} \
    USER=${USER} \
    CUSTOMUID=${CUSTOMUID} \
    CUSTOMGID=${CUSTOMGID} \
    APACHE= ${APACHE}

#COMANDOS PARA SETEAR EL PROPIETARIO DEL DIRECTORIO
RUN echo "USUARIO: ${USER}"    
RUN echo "CUSTOMUID: ${CUSTOMUID}"    
RUN echo "CUSTOMGID: ${CUSTOMGID}"
RUN echo "APACHE: ${APACHE}"

COPY ./deploy/mysql/my.cnf /etc/mysql/conf.d/my.cnf
COPY ./deploy/mysql/init.sql  /docker-entrypoint-initdb.d/init.sql