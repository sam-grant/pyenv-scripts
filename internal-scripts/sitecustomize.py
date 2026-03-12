# AI-developed fix  
# Solution to TensorFlow and XRootD SSL context conflict in sitecustomize.py
# Pre-initialize XRootD SSL context before TensorFlow can interfere.
# TensorFlow's gRPC modifies the global OpenSSL state at import time,
# which breaks XRootD's TLS certificate validation. Loading XRootD
# first ensures its SSL context is established correctly.
try:
    from XRootD import client as _xrd_client
except ImportError:
    pass
