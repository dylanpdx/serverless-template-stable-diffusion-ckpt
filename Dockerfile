# Must use a Cuda version 11+
FROM pytorch/pytorch:1.11.0-cuda11.3-cudnn8-runtime

WORKDIR /

# Install git
RUN apt-get update && apt-get install -y git wget

# Install python packages
RUN pip3 install --upgrade pip
ADD requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
# For conversion of checkpoints
RUN pip install omegaconf==2.2.3

# We add the banana boilerplate here
ADD server.py .
EXPOSE 8000

ADD convert_original_stable_diffusion_to_diffusers.py .

# Add URL to ckpt file
RUN wget -O model.ckpt "CKPT_FILE_URL"
RUN mkdir /sdmodel
RUN python convert_original_stable_diffusion_to_diffusers.py --checkpoint_path model.ckpt --dump_path /sdmodel
RUN rm model.ckpt

# Add your custom app code, init() and inference()
ADD app.py .

CMD python3 -u server.py
