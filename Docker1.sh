cd /kickstart
ls -lh
sudo apt-get install -y python3 python3-pip 3 # install the neccesary packes in your instance
pip3 install tornado
python3 web-server.py &
curl http://localhost:8888
kill %1

# Package Using Docker
cat Dockerfile
sudo docker build -t py-web-server:v1 .
sudo docker run -d -p 8888:8888 --name py-web-server -h my-web-server py-web-server:v1
curl http://localhost:8888
sudo docker rm -f py-web-server

#Upload the Image to a Registry
sudo usermod -aG docker $USER
# close the instance
cd /kickstart
export GCP_PROJECT=`gcloud config list core/project --format='value(core.project)'`
docker build -t "gcr.io/${GCP_PROJECT}/py-web-server:v1" .

#Make the Image Publicly Accessible
PATH=/usr/lib/google-cloud-sdk/bin:$PATH
gcloud auth configure-docker
docker push gcr.io/${GCP_PROJECT}/py-web-server:v1 # Push the image to gcr.io
# To see the image stored as a bucket (object) in your Google Cloud Storage repository, click the Navigation menu icon and select Storage.
# Update the permissions on Google Cloud Storage to make your image repository publicly accessible.
gsutil defacl ch -u AllUsers:R gs://artifacts.${GCP_PROJECT}.appspot.com
gsutil acl ch -r -u AllUsers:R gs://artifacts.${GCP_PROJECT}.appspot.com
gsutil acl ch -u AllUsers:R gs://artifacts.${GCP_PROJECT}.appspot.com

# Run the Web Server From Any Machine
docker run -d -p 8888:8888 -h my-web-server gcr.io/${GCP_PROJECT}/py-web-server:v1
