FROM lnfu/safmc-d2-env:gazebo AS base

RUN git clone https://github.com/eProsima/Micro-XRCE-DDS-Agent.git \
    && cd Micro-XRCE-DDS-Agent \
    && mkdir build && cd build \
    && cmake .. \
    && make -j$(nproc) \
    && sudo make install \
    && sudo ldconfig /usr/local/lib \
    && cd .. \
    && rm -rf Micro-XRCE-DDS-Agent

CMD ["MicroXRCEAgent", "udp4", "-p", "8888"]
