FROM debian:11

WORKDIR /root

SHELL ["/bin/bash", "-c"]

ENV PATH "/root/miniconda3/bin:/root/nextflow.dir/bin:$PATH"

RUN ln -sf /bin/bash /bin/sh && \
  ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
  mkdir -p /root/nextflow.dir/bin

#### copy pre-downloaded nextflow-all file into specific directory ####
#COPY ./nextflow-all/nextflow-22.10.7-all /root/nextflow.dir/bin/nextflow
########

RUN cd /root && \
  #### for Chinese user ####
  # sed -i s/deb.debian.org/ftp.tw.debian.org/g /etc/apt/sources.list && \
  # sed -i s/security.debian.org/ftp.tw.debian.org/g /etc/apt/sources.list && \
  ########

  apt update && apt dist-upgrade -y && \
  apt install -y wget openjdk-17-jre

#### nextflow ####
RUN cd /root && \
  wget -O nextflow.dir/bin/nextflow https://github.com/nextflow-io/nextflow/releases/download/v22.10.7/nextflow-22.10.7-all && \
  chmod +x nextflow.dir/bin/nextflow && \
  echo 'export PATH="/root/nextflow.dir/bin:${PATH}"' >> .bashrc

RUN cd /root && \
  #### miniconda3 ####
  wget 'https://repo.anaconda.com/miniconda/Miniconda3-py39_23.1.0-1-Linux-x86_64.sh' && \
  bash ./Miniconda3-py39_23.1.0-1-Linux-x86_64.sh -b && \
  rm -f Miniconda3-py39_23.1.0-1-Linux-x86_64.sh && \
  ln -sf /root/miniconda3 /opt/miniconda3 && \
  . '/root/miniconda3/etc/profile.d/conda.sh' && \
  conda init bash && \
  ########
  conda update conda && \

  conda activate base && \

  ########
  conda install -y zip && \
  conda install -y hdf5 && \
  conda install -y cmake && \
  conda install -y pkg-config && \
  ########

  ########
  conda install -y r-essentials && \
  conda install -y r-biocmanager && \
  conda install -y r-devtools && \

  conda install -y r-r.utils && \
  conda install -y r-systemfonts && \
  conda install -y r-hdf5r && \
  conda install -y r-dbi && \
  conda install -y r-shiny && \
  conda install -y r-shinywidgets && \
  conda install -y r-plotly && \
  conda install -y r-dt
########

# #### PPP ####
# #pip3 config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple && \

# echo $'\
# options("repos" = c(CRAN="https://cran.csie.ntu.edu.tw/"))\n\
# options(BioC_mirror="https://bioconductor.riken.jp")\
# ' > .Rprofile && \
# ########

RUN cd /root && \
  #### for Chinese user ####
  pip3 config set global.index-url https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple && \

  echo $'\
  options("repos" = c(CRAN="https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))\n\
  options(BioC_mirror="https://mirrors.tuna.tsinghua.edu.cn/bioconductor")\
  ' > .Rprofile && \
  ########

  #### Update packages ####
  R -e 'install.packages("reticulate")' && \
  R -e 'install.packages("ggplot2")' && \
  R -e 'install.packages("RcppCNPy")'

RUN cd /root && \
  #### R Anndata ####
  . '/root/miniconda3/etc/profile.d/conda.sh' && \
  conda init bash && \
  conda create -y -n r-reticulate python=3.9 && \

  conda activate r-reticulate && \
  ## GPU acceleration for scvi-tools ##
  # pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
  ####
  pip install anndata scvi-tools && \
  conda deactivate && \

  R -e 'install.packages("anndata")' && \

  export RETICULATE_MINICONDA_PATH="/root/miniconda3"
########

RUN cd /root && \
  #### Bio-tools ####
  R -e 'BiocManager::install("Seurat")'

RUN cd /root && \
  R -e 'BiocManager::install("glmGamPoi")' && \
  R -e 'BiocManager::install("LoomExperiment")' && \
  R -e 'BiocManager::install("org.Hs.eg.db")' && \
  R -e 'BiocManager::install("org.Mm.eg.db")' && \
  R -e 'BiocManager::install("ComplexHeatmap")' && \
  R -e 'BiocManager::install("ggblur")'

RUN cd /root && \
  R -e 'BiocManager::install("SingleR")' && \
  R -e 'BiocManager::install("batchelor")' && \
  R -e 'BiocManager::install("harmony")' && \
  R -e 'BiocManager::install("monocle")' && \
  R -e 'BiocManager::install("clusterProfiler")'

RUN cd /root && \
  #R -e 'usethis::create_github_token()' && \
  #R -e 'gitcreds::gitcreds_set()' && \
  R -e 'devtools::install_github("chris-mcginnis-ucsf/DoubletFinder", host = "https://api.github.com")' && \
  R -e 'devtools::install_github("satijalab/seurat-wrappers", host = "https://api.github.com")' && \
  R -e 'devtools::install_github("cellgeni/sceasy", host = "https://api.github.com")' && \
  R -e 'devtools::install_github("ShellyCoder/cellcall", host = "https://api.github.com")' && \
  R -e 'devtools::install_github("sqjin/CellChat", host = "https://api.github.com")'
########

RUN cd /root && \
  R -e 'BiocManager::install("Biobase")' && \
  R -e 'BiocManager::install("VGAM")' && \
  R -e 'BiocManager::install("DDRTree")' && \
  R -e 'BiocManager::install("BiocGenerics")' && \
  R -e 'BiocManager::install("HSMMSingleCell")' && \
  R -e 'BiocManager::install("combinat")' && \
  R -e 'BiocManager::install("fastICA")' && \
  R -e 'BiocManager::install("leidenbase")' && \
  R -e 'BiocManager::install("limma")' && \
  R -e 'BiocManager::install("qlcMatrix")' && \
  R -e 'BiocManager::install("slam")' && \
  R -e 'BiocManager::install("viridis")' && \
  R -e 'BiocManager::install("biocViews")'

# RUN cd /root && \
#   R -e 'bio_packages = c("Biobase", "VGAM", "DDRTree", "BiocGenerics", "HSMMSingleCell", "combinat", "fastICA", "leidenbase", "limma", "qlcMatrix", "slam", "viridis", "biocViews")' && \
#   R -e 'source("http://bioconductor.org/biocLite.R")' && \
#   R -e 'biocLite(bio_packages)'

RUN cd /root && \
  ### fix up monocle2 ####
  rm -rf /root/miniconda3/lib/R/library/monocle && \
  wget https://bioconductor.org/packages/3.16/bioc/src/contrib/monocle_2.26.0.tar.gz && \
  tar zxf monocle_2.26.0.tar.gz && \
  sed -i s/if\(class\(projection\)/#if\(class\(projection\)/ monocle/R/order_cells.R && \
  R CMD INSTALL monocle && \
  rm -rf monocle monocle_2.26.0.tar.gz
#######

RUN cd /root && \
  #### leidenalg ####
  pip install leidenalg
########

RUN cd /root && \
  . '/root/miniconda3/etc/profile.d/conda.sh' && \
  conda init bash && \
  #### put SPRING into GRACE/grace/utils ####
  conda create -y -n spring python=2.7 && \

  conda activate spring && \
  pip install pandas matplotlib scikit-learn && \
  conda deactivate
########

RUN cd /root && \
  . '/root/miniconda3/etc/profile.d/conda.sh' && \
  conda init bash && \
  #### CellphoneDB ####
  conda create -y -n cellphonedb python=3.7 && \

  conda activate cellphonedb && \
  conda install -y r-essentials && \
  R -e 'install.packages("pheatmap")' && \
  pip install markupsafe==2.0.1 && \
  pip install cellphonedb && \
  cellphonedb database download --version v3.0.0 && \
  conda deactivate && \
  ########

  apt autoremove --purge && apt autoclean

RUN cd /root && \
  apt install -y unzip && \
  mkdir data && \
  wget -O /root/data/grace.zip https://rce.tw:3009/grace.zip --no-check-certificate && \
  cd /root/data && \
  unzip grace.zip && \
  mkdir /root/data/grace-1.1/dbs
# cd /root/data/grace-1.1

WORKDIR /root/data/grace-1.1
CMD Rscript app.R

EXPOSE 8081