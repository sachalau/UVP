FROM continuumio/miniconda3:4.3.27

RUN conda config --add channels defaults && conda config --add channels conda-forge && conda config --add channels bioconda

RUN useradd -r -u 1080 pipeline_user

RUN apt -y update

WORKDIR /home/pipeline_user/

RUN git clone https://github.com/CPTR-ReSeqTB/UVP.git

RUN mkdir /opt/conda/envs/

ENV conda_folder /opt/conda/envs/

RUN conda env create -f UVP/environment.yml

RUN wget https://storage.googleapis.com/pub/gsutil.tar.gz

RUN tar xfz gsutil.tar.gz -C $HOME

RUN echo export PATH=${PATH}:$HOME/gsutil >> ~/.bashrc

RUN $HOME/gsutil/gsutil cp gs://gatk-software/package-archive/gatk/GenomeAnalysisTK-3.6-0-g89b7209.tar.bz2 UVP/

WORKDIR UVP

RUN tar xf GenomeAnalysisTK-3.6-0-g89b7209.tar.bz2

RUN echo "source activate reseqtb-uvp" > /home/pipeline_user/.bashrc

ENV PATH /opt/conda/envs/reseqtb-uvp/bin:$PATH

RUN pip install -e .

RUN snpEff download m_tuberculosis_H37Rv

RUN gatk3-register GenomeAnalysisTK.jar

RUN chown -R pipeline_user /home/pipeline_user/

USER pipeline_user







