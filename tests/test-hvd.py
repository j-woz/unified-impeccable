
# Need ITEX on Aurora, else TF segfault at exit!
import intel_extension_for_tensorflow as itex
import tensorflow as tf
print("TF version: " + tf.__version__)
# import horovod.tensorflow as hvd
print("OK")
