import onnx
import sys

def downgrade_ir_version(input_path, output_path, target_ir_version=9):
    try:
        model = onnx.load(input_path)
        print(f"Original IR version: {model.ir_version}")
        
        if model.ir_version <= target_ir_version:
            print(f"IR version is already {model.ir_version}. No change needed.")
        else:
            model.ir_version = target_ir_version
            onnx.save(model, output_path)
            print(f"Successfully downgraded IR version to {target_ir_version} and saved to {output_path}")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    input_file = "assets/models/annva_model.onnx"
    output_file = "assets/models/annva_model.onnx"
    downgrade_ir_version(input_file, output_file)
