FROM ubuntu:18.04 as linux
RUN apt update && \
	apt install -y openvswitch-switch mininet iproute2 arping netcat \
                curl inetutils-ping inetutils-traceroute \
                build-essential gdb git nano screen python python-pip sudo && \
        pip install typing && \
        pip install mininet twisted ltprotocol
RUN apt install -y python3 python3-pip && \
        pip3 install -U pip && \
	pip3 install -U cryptography && \
        pip3 install mininet pexpect scapy
WORKDIR /
COPY project-base project-base


FROM --platform=linux/amd64 ubuntu:18.04 as wsl-build
RUN apt update && \
	apt install -y build-essential flex bison libssl-dev libelf-dev git dwarves bc python3
RUN git clone --depth 1 https://github.com/microsoft/WSL2-Linux-Kernel.git --branch linux-msft-wsl-5.15.y --single-branch /wsl-kernel
COPY windows-configs/.config /wsl-kernel/.config
RUN yes "" | make -C /wsl-kernel -j $(expr $(nproc) - 1) SUBDIRS=net/openvswitch modules

FROM wsl-build as windows-kernel
RUN yes "" | make -C /wsl-kernel -j $(expr $(nproc) - 1)
RUN make -C /wsl-kernel install

FROM linux as windows
COPY --from=wsl-build /wsl-kernel /wsl-kernel
RUN make -C /wsl-kernel SUBDIRS=net/openvswitch modules_install
