#!/usr/bin/env python3
"""
Setup and run the complete PDF comparison pipeline
"""

import os
import subprocess
import sys
from pathlib import Path

def install_requirements():
    """Install required Python packages"""
    print("Installing required packages...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
    print("✓ Packages installed successfully")

def setup_directories():
    """Create necessary directories"""
    directories = [
        "assets/pdfs",
        "assets/extracted_content",
        "assets/generated_data"
    ]
    
    for directory in directories:
        Path(directory).mkdir(parents=True, exist_ok=True)
        print(f"✓ Created directory: {directory}")

def check_gemini_api_key():
    """Check if Gemini API key is set"""
    api_key = os.getenv('GEMINI_API_KEY')
    if not api_key:
        print("\n⚠️  GEMINI_API_KEY environment variable not set!")
        print("Please get your API key from: https://makersuite.google.com/app/apikey")
        print("Then set it as an environment variable:")
        print("  Windows: set GEMINI_API_KEY=your_api_key_here")
        print("  Linux/Mac: export GEMINI_API_KEY=your_api_key_here")
        return False
    print("✓ Gemini API key found")
    return True

def run_extraction():
    """Run PDF content extraction"""
    print("\n🔍 Running PDF content extraction...")
    try:
        subprocess.check_call([sys.executable, "pdf_content_extractor.py"])
        print("✓ PDF extraction completed")
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ PDF extraction failed: {e}")
        return False

def run_ai_comparison():
    """Run AI comparison generation"""
    print("\n🤖 Running AI comparison generation...")
    try:
        subprocess.check_call([sys.executable, "ai_comparison_generator.py"])
        print("✓ AI comparison generation completed")
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ AI comparison generation failed: {e}")
        return False

def main():
    """Main setup and run function"""
    print("🚀 Setting up PDF Comparison System")
    print("=" * 50)
    
    # Step 1: Install requirements
    try:
        install_requirements()
    except Exception as e:
        print(f"✗ Failed to install requirements: {e}")
        return
    
    # Step 2: Setup directories
    setup_directories()
    
    # Step 3: Check API key
    if not check_gemini_api_key():
        return
    
    # Step 4: Check for PDF files
    pdf_dir = Path("assets/pdfs")
    pdf_files = list(pdf_dir.glob("*.pdf"))
    
    if not pdf_files:
        print(f"\n⚠️  No PDF files found in {pdf_dir}")
        print("Please add your PDF files to the assets/pdfs directory")
        return
    
    print(f"✓ Found {len(pdf_files)} PDF files to process")
    
    # Step 5: Run extraction
    if not run_extraction():
        return
    
    # Step 6: Run AI comparison
    if not run_ai_comparison():
        return
    
    print("\n🎉 Setup completed successfully!")
    print("\nGenerated files:")
    print("  - assets/extracted_content/*_content.json (PDF content)")
    print("  - assets/ai_comparisons.json (AI-generated comparisons)")
    print("\nYou can now integrate these files into your Flutter app!")

if __name__ == "__main__":
    main()