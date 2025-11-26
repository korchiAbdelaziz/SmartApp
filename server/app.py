import os
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
from PIL import Image, ImageOps
import io
import hashlib
import datetime

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Try to import tflite_runtime first (lighter), fall back to tensorflow
try:
    from tflite_runtime.interpreter import Interpreter
except ImportError:
    from tensorflow.lite.python.interpreter import Interpreter

# Configuration
MODEL_PATH = os.getenv('MODEL_PATH', 'model.tflite')
LABELS_PATH = os.getenv('LABELS_PATH', 'labels.txt')

# Initialize interpreter
interpreter = None
labels = []
input_size = None  # Will auto-detect from model

def init_model():
    global interpreter, labels, input_size
    if not os.path.exists(MODEL_PATH):
        raise FileNotFoundError(f"Model not found at {MODEL_PATH}")
    if not os.path.exists(LABELS_PATH):
        raise FileNotFoundError(f"Labels not found at {LABELS_PATH}")
    
    interpreter = Interpreter(model_path=MODEL_PATH)
    interpreter.allocate_tensors()
    
    # Auto-detect input size from model
    input_details = interpreter.get_input_details()
    # input_shape is typically [batch_size, height, width, channels]
    input_shape = input_details[0]['shape']
    input_size = (input_shape[1], input_shape[2])  # (height, width)
    
    with open(LABELS_PATH, 'r', encoding='utf-8') as f:
        labels = [line.strip() for line in f if line.strip()]
    
    print(f"✓ Model loaded: {MODEL_PATH}")
    print(f"✓ Model input size: {input_size}")
    # Print labels with indices for verification
    for i, lab in enumerate(labels):
        print(f"  label[{i}] = {lab}")
    print(f"✓ Labels loaded: {len(labels)} classes")

def preprocess_image(image_bytes, target_size=None):
    """Preprocess image to match model expectations.
    
    Model expects uint8 (0-255) - the Rescaling(1./255) layer inside the model
    will normalize to (0-1) range. This matches the training pipeline.
    """
    if target_size is None:
        target_size = input_size  # Use auto-detected size (height, width)

    try:
        # Load image and handle EXIF orientation
        image = Image.open(io.BytesIO(image_bytes))
        image = ImageOps.exif_transpose(image).convert('RGB')

        # Ensure target_size is (height, width)
        target_h, target_w = int(target_size[0]), int(target_size[1])

        # Resize while preserving aspect ratio, then center-crop to target
        src_w, src_h = image.size
        # scale to cover the target area
        scale = max(target_w / src_w, target_h / src_h)
        new_w = max(1, int(src_w * scale))
        new_h = max(1, int(src_h * scale))
        image = image.resize((new_w, new_h), Image.BILINEAR)

        left = (new_w - target_w) // 2
        top = (new_h - target_h) // 2
        image = image.crop((left, top, left + target_w, top + target_h))

        # Convert to uint8 array (0-255) - DON'T normalize here!
        # The model's Rescaling(1./255) layer will do it
        arr = np.asarray(image).astype('uint8')
        
        arr = np.expand_dims(arr, axis=0)  # Add batch dimension [1, H, W, C]

        return arr
    except Exception as e:
        raise ValueError(f"Image preprocessing failed: {str(e)}")

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({'status': 'ok', 'model': MODEL_PATH, 'labels': len(labels)})

@app.route('/predict', methods=['POST', 'OPTIONS'])
def predict():
    """Predict fruit class from image."""
    if request.method == 'OPTIONS':
        return '', 204
    
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    try:
        file = request.files['file']
        img_bytes = file.read()
        # Compute checksum of original bytes for debugging/comparison
        sha = hashlib.sha256(img_bytes).hexdigest()[:12]
        print(f"Received file: filename={getattr(file, 'filename', 'unknown')}, sha={sha}, size={len(img_bytes)} bytes")
        
        # Preprocess with auto-detected size
        input_data = preprocess_image(img_bytes)

        # DEBUG: Always save and log pixel stats
        debug_dir = os.path.join(os.getcwd(), 'debug_uploads')
        os.makedirs(debug_dir, exist_ok=True)
        
        # input_data is [1, H, W, C] uint8 (0-255)
        prep_img_vis = input_data[0]  # Already uint8
        prep_img_obj = Image.fromarray(prep_img_vis)
        prep_path = os.path.join(debug_dir, f'preprocessed_{sha}.png')
        prep_img_obj.save(prep_path)
        
        # Log input tensor stats
        print(f"  Input uint8 range: min={input_data.min()}, max={input_data.max()}, mean={input_data.mean():.1f}")
        print(f"  Saved preprocessed image: {prep_path}")
        
        # Also save original
        orig_path = os.path.join(debug_dir, f'original_{sha}.jpg')
        with open(orig_path, 'wb') as f:
            f.write(img_bytes)
        
        # Get tensor details
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        # Debug: print input tensor expectations
        print(f"Input details: shape={input_details[0]['shape']}, dtype={input_details[0]['dtype']}, quant={input_details[0].get('quantization')}")

        # Handle channel ordering: model may expect NHWC or NCHW
        in_shape = input_details[0]['shape']
        # input_data shape is [1, H, W, C]
        if len(in_shape) == 4 and in_shape[-1] != 3 and in_shape[1] == 3:
            # Model expects channels-first [1, C, H, W]
            input_data = np.transpose(input_data, (0, 3, 1, 2))

        # Input is already uint8 from preprocess_image, just ensure correct dtype
        dtype = input_details[0]['dtype']
        input_data = input_data.astype(dtype)

        # Set tensor and invoke
        try:
            interpreter.set_tensor(input_details[0]['index'], input_data)
        except Exception as e:
            print(f"Set tensor failed: expected {input_details[0]['shape']}, got {input_data.shape}, dtype={input_data.dtype}")
            raise
        interpreter.invoke()
        
        # Get raw output
        output_raw = interpreter.get_tensor(output_details[0]['index'])

        # Handle different output shapes [1, num_classes] or [num_classes]
        if output_raw.ndim > 1:
            output_raw = output_raw[0]

        # Dequantize output if necessary
        out_dtype = output_details[0]['dtype']
        out_quant = output_details[0].get('quantization', (0.0, 0))
        out_scale, out_zero = (0.0, 0)
        if isinstance(out_quant, (list, tuple)) and len(out_quant) >= 2:
            out_scale, out_zero = out_quant[0], int(out_quant[1])

        if out_dtype == np.uint8:
            if out_scale not in (0.0, None):
                output_f = (output_raw.astype(np.float32) - out_zero) * out_scale
            else:
                # Fallback: scale 255
                output_f = (output_raw.astype(np.float32) - 0) / 255.0
        else:
            output_f = output_raw.astype(np.float32)

        # Log outputs for debugging
        try:
            print(f"Output (post-dequant) sample: {output_f.tolist()}")
            print(f"Output stats: min={output_f.min():.4f}, max={output_f.max():.4f}, range={output_f.max() - output_f.min():.4f}")
            if (output_f.max() - output_f.min()) < 0.5:
                print("  ⚠️  WARNING: Low output range! Logits are too close. Check preprocessing!")
        except Exception:
            print("Output (post-dequant) logging failed")

        # If outputs don't look like probabilities, apply softmax
        s = float(np.sum(output_f))
        if not (0.99 <= s <= 1.01):
            # apply softmax to get probabilities
            exps = np.exp(output_f - np.max(output_f))
            probs = exps / np.sum(exps)
        else:
            probs = output_f

        # Find top prediction
        top_idx = int(np.argmax(probs))
        confidence = float(np.max(probs))
        label = labels[top_idx] if top_idx < len(labels) else 'Unknown'

        # Build readable predictions dict
        all_preds = {labels[i]: float(probs[i]) for i in range(min(len(labels), len(probs)))}

        print(f"Predicted: idx={top_idx}, label={label}, confidence={confidence}")

        return jsonify({
            'label': label,
            'index': top_idx,
            'confidence': confidence,
            'all_predictions': all_preds
        })
    
    except Exception as e:
        print(f"Prediction error: {e}")
        return jsonify({'error': str(e)}), 500

@app.errorhandler(404)
def not_found(e):
    return jsonify({'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def server_error(e):
    return jsonify({'error': 'Server error'}), 500

if __name__ == '__main__':
    try:
        init_model()
        print(f"\n{'='*50}")
        print("🍎 Fruit Classifier Server Started")
        print(f"{'='*50}")
        print("📍 Server running on http://localhost:5000")
        print("🔍 Health check: http://localhost:5000/health")
        print("📤 Upload image: POST http://localhost:5000/predict")
        print(f"{'='*50}\n")
        
        app.run(host='0.0.0.0', port=5000, debug=True)
    except Exception as e:
        print(f"❌ Failed to start server: {e}")
        exit(1)
