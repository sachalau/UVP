FROM continuumio/miniconda3:4.3.27

RUN conda config --add channels defaults && conda config --add channels conda-forge && conda config --add channels bioconda

RUN useradd -r -u 1080 pipeline_user

RUN apt -y update

WORKDIR /home/pipeline_user//

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

RUN apt install unzip

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

RUN unzip awscliv2.zip

RUN ./aws/install

RUN rm -rf aws*

RUN conda install sra-tools=2.10 entrez-direct

USER pipeline_user

ADD fetch_and_run.sh /home/pipeline_user/fetch_and_run.sh

ENTRYPOINT ["/home/pipeline_user/fetch_and_run.sh"]





