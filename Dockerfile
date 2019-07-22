FROM genepattern/docker-r-2-5

COPY ./module /ESPPredictor
COPY ./compiled /ESPPredictor/compiled
RUN cd /ESPPredictor/lib  && \
    Rscript /ESPPredictor/lib/installit.R

RUN mkdir /mcr && \
    wget https://ssd.mathworks.com/supportfiles/downloads/R2018a/deployment_files/R2018a/installers/glnxa64/MCR_R2018a_glnxa64_installer.zip && \
    mv /MCR_R2018a_glnxa64_installer.zip /mcr

RUN cd /mcr && \
    unzip MCR_R2018a_glnxa64_installer.zip && \ 
    ./install -mode silent -agreeToLicense yes

ENV LD_LIBRARY_PATH /usr/local/MATLAB/MATLAB_Runtime/v94/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v94/bin/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v94/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Runtime/v94/extern/bin/glnxa64:${LD_LIBRARY_PATH}

 
