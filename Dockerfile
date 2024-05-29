FROM yusun9/wham-vitpose-dpvo-cuda11.3-python3.9:latest
# flask default port
EXPOSE 5000
RUN pip install flask
RUN pip install neopyter>=0.2.3
RUN pip install jupyterlab
CMD flask --app server run -p 5000 -h 0.0.0.0

