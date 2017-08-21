FROM centos:latest
ENV CHPL_COMM=gasnet
ENV CHPL_LAUNCHER=amudprun
ENV CHPL_HOME=/home/chapel/chapel-1.15.0
ENV PATH=$PATH:$CHPL_HOME/bin/linux64

RUN adduser chapel
RUN yum install -y make gcc gcc-c++ perl which net-tools less openssh openssh-clients openssh-server bzip2 m4 file sudo bind-utils
RUN cd /tmp && curl -L https://github.com/openshift/origin/releases/download/v1.5.1/openshift-origin-client-tools-v1.5.1-7b451fc-linux-64bit.tar.gz -o oc.tar.gz && tar xzf oc.tar.gz && mv openshift-origin-client-tools-v1.5.1-7b451fc-linux-64bit/oc /usr/local/bin 
RUN cd /home/chapel && curl -L https://github.com/chapel-lang/chapel/releases/download/1.15.0/chapel-1.15.0.tar.gz -o chapel.tar.gz && tar xzf chapel.tar.gz && cd chapel-1.15.0 && source util/quickstart/setchplenv.bash

RUN cd $CHPL_HOME && make 
RUN chmod +x /home/chapel/run.sh &&  chown -R chapel.chapel /home/chapel
RUN ssh-keygen -A
RUN sed -i.bak -e "\$aStrictHostKeyChecking no\nUserKnownHostsFile=/dev/null" /etc/ssh/ssh_config
RUN sed -i.bak "s/UsePrivilegeSeparation sandbox/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
RUN sed -i.bak "s/#Port 22/Port 2222/g" /etc/ssh/sshd_config
RUN mkdir /home/chapel/mnt && chmod a+rwx /home/chapel/mnt && touch /var/log/sshd.log && chmod a+rwx /var/log/sshd.log && chmod a+r /etc/ssh/*config && chmod a+r /etc/ssh/*key && touch /var/run/sshd.pid && chmod a+rw /var/run/sshd.pid
USER chapel
RUN ssh-keygen -t rsa -N "" -f /home/chapel/.ssh/id_rsa
RUN cp /home/chapel/.ssh/id_rsa.pub /home/chapel/.ssh/authorized_keys
RUN chmod 600 /home/chapel/.ssh/authorized_keys
RUN cd $CHPL_HOME && chpl -o /home/chapel/hello6-taskpar-dist $CHPL_HOME/examples/hello6-taskpar-dist.chpl
COPY run.sh /home/chapel
EXPOSE 2222
ENTRYPOINT /usr/sbin/sshd -E /var/log/sshd.log  && tail -f /var/log/sshd.log
