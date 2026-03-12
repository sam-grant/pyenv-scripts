import tensorflow as tf
from pyutils.pyprocess import Processor
file_list_path="nts.mu2e.ensembleMDS3aMix1BBTriggered.MDC2025-001.001430_00000974.root"
branches=["event"]
processor = Processor(use_remote=True, location="disk")
data = processor.process_data(file_name=file_list_path, branches=branches)
print(data)