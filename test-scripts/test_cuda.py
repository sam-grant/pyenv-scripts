import sys
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'

print(f"🐍 Python: {sys.version}\n")

# TensorFlow
try:
    import tensorflow as tf
    print(f"🧠 TensorFlow: {tf.__version__}")
    gpus = tf.config.list_physical_devices('GPU')
    if gpus:
        print(f"  ✅ CUDA: working ({len(gpus)} GPU(s))")
    else:
        print("  ❌ CUDA: not available")
except ImportError:
    print("🧠 TensorFlow: not installed")
print()

# PyTorch
try:
    import torch
    print(f"🔥 PyTorch: {torch.__version__}")
    if torch.cuda.is_available():
        print(f"  ✅ CUDA: working (v{torch.version.cuda}, {torch.cuda.get_device_name(0)}, {torch.cuda.device_count()} device(s))")
    else:
        print("  ❌ CUDA: not available")
except ImportError:
    print("🔥 PyTorch: not installed")
print()

# XGBoost
try:
    import xgboost as xgb
    import numpy as np
    print(f"🚀 XGBoost: {xgb.__version__}")
    try:
        dtrain = xgb.DMatrix(np.array([[1, 2], [3, 4]]), label=[0, 1])
        xgb.train({"device": "cuda", "max_depth": 1}, dtrain, num_boost_round=1)
        print("  ✅ CUDA: working")
    except Exception as e:
        print(f"  ❌ CUDA: {e}")
except ImportError:
    print("🚀 XGBoost: not installed")