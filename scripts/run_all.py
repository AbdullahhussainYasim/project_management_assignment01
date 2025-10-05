#!/usr/bin/env python3
"""
Run All - Complete pipeline in one script
"""

import subprocess
import sys
import os

def run_script(script_name, description):
    """Run a Python script and handle errors"""
    print(f"\n🔄 {description}")
    print("-" * 40)
    
    try:
        result = subprocess.run([sys.executable, script_name], 
                              capture_output=True, 
                              text=True, 
                              cwd=os.path.dirname(os.path.abspath(__file__)))
        
        if result.returncode == 0:
            print(result.stdout)
            print(f"✅ {description} completed successfully")
            return True
        else:
            print(f"❌ {description} failed:")
            print(result.stderr)
            return False
            
    except Exception as e:
        print(f"❌ Error running {script_name}: {e}")
        return False

def main():
    """Run the complete pipeline"""
    print("🚀 PDF Comparison System - Complete Pipeline")
    print("=" * 50)
    
    scripts = [
        ("simple_setup.py", "Setting up environment"),
        ("simple_extractor.py", "Extracting PDF content"),
        ("simple_comparison.py", "Generating AI comparisons")
    ]
    
    for script, description in scripts:
        success = run_script(script, description)
        if not success:
            print(f"\n❌ Pipeline stopped at: {description}")
            print("Please check the errors above and try again.")
            return
    
    print("\n" + "=" * 50)
    print("🎉 Complete pipeline finished successfully!")
    print("\nGenerated files:")
    print("  📁 assets/extracted_content/ - PDF content files")
    print("  📄 assets/ai_comparisons.json - AI comparisons")
    print("\n💡 Next steps:")
    print("  1. Copy ai_comparisons.json to your Flutter assets/")
    print("  2. Update your Flutter app to load the new data")
    print("  3. Test the enhanced search and comparison features")

if __name__ == "__main__":
    main()