#!/usr/bin/env python3
"""
Simple setup script for PDF comparison system
"""

import os
import sys
import subprocess
from pathlib import Path

def check_python_version():
    """Check if Python version is compatible"""
    if sys.version_info < (3, 7):
        print("Error: Python 3.7 or higher is required")
        return False
    print(f"✓ Python {sys.version_info.major}.{sys.version_info.minor} detected")
    return True

def install_packages():
    """Install required packages one by one"""
    packages = [
        "PyMuPDF",
        "google-generativeai",
        "pathlib2"
    ]
    
    for package in packages:
        try:
            print(f"Installing {package}...")
            subprocess.check_call([sys.executable, "-m", "pip", "install", package], 
                                stdout=subprocess.DEVNULL, 
                                stderr=subprocess.DEVNULL)
            print(f"✓ {package} installed successfully")
        except subprocess.CalledProcessError:
            print(f"✗ Failed to install {package}")
            print(f"Try manually: pip install {package}")

def create_directories():
    """Create necessary directories"""
    directories = [
        "assets",
        "assets/pdfs",
        "assets/extracted_content",
        "assets/generated_data"
    ]
    
    for directory in directories:
        Path(directory).mkdir(parents=True, exist_ok=True)
        print(f"✓ Created directory: {directory}")

def check_api_key():
    """Check if API key is set"""
    api_key = os.getenv('GEMINI_API_KEY')
    if not api_key:
        print("\n⚠️  GEMINI_API_KEY not set!")
        print("Get your API key from: https://makersuite.google.com/app/apikey")
        print("\nTo set the API key:")
        print("Windows: set GEMINI_API_KEY=your_key_here")
        print("Linux/Mac: export GEMINI_API_KEY=your_key_here")
        print("\n💡 Note: After setting the environment variable, restart your terminal/command prompt")
        return False
    print(f"✓ Gemini API key found: {api_key[:10]}...")
    return True

def check_pdf_files():
    """Check for PDF files"""
    # Check multiple possible locations
    possible_paths = [
        Path("assets/pdfs"),
        Path("../assets/pdfs"),
        Path("./assets/pdfs")
    ]
    
    pdf_files = []
    pdf_dir = None
    
    for path in possible_paths:
        if path.exists():
            files = list(path.glob("*.pdf"))
            if files:
                pdf_files = files
                pdf_dir = path
                break
    
    if not pdf_files:
        print(f"\n⚠️  No PDF files found in any of these locations:")
        for path in possible_paths:
            print(f"    - {path.absolute()}")
        print("Please add your PDF files to one of these directories")
        return False
    
    print(f"✓ Found {len(pdf_files)} PDF files in {pdf_dir}:")
    for pdf_file in pdf_files:
        print(f"  - {pdf_file.name}")
    return True

def main():
    """Main setup function"""
    print("🚀 Simple PDF Comparison Setup")
    print("=" * 40)
    
    # Check Python version
    if not check_python_version():
        return
    
    # Install packages
    print("\n📦 Installing packages...")
    install_packages()
    
    # Create directories
    print("\n📁 Creating directories...")
    create_directories()
    
    # Check API key
    print("\n🔑 Checking API key...")
    has_api_key = check_api_key()
    
    # Check PDF files
    print("\n📄 Checking PDF files...")
    has_pdfs = check_pdf_files()
    
    print("\n" + "=" * 40)
    if has_api_key and has_pdfs:
        print("✅ Setup completed! You can now run:")
        print("   python simple_extractor.py")
    else:
        print("⚠️  Setup incomplete. Please:")
        if not has_api_key:
            print("   - Set your GEMINI_API_KEY")
        if not has_pdfs:
            print("   - Add PDF files to assets/pdfs/")

if __name__ == "__main__":
    main()