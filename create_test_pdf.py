#!/usr/bin/env python3
"""
Simple script to create test PDF files for the Flutter app
Run: python create_test_pdf.py
"""

try:
    from reportlab.pdfgen import canvas
    from reportlab.lib.pagesizes import letter
    import os
    
    def create_test_pdf(filename, title, content):
        """Create a simple test PDF"""
        c = canvas.Canvas(filename, pagesize=letter)
        width, height = letter
        
        # Title
        c.setFont("Helvetica-Bold", 24)
        c.drawString(50, height - 100, title)
        
        # Content
        c.setFont("Helvetica", 12)
        y_position = height - 150
        
        for line in content:
            c.drawString(50, y_position, line)
            y_position -= 20
            
        c.save()
        print(f"Created: {filename}")
    
    # Create assets/pdfs directory if it doesn't exist
    os.makedirs("assets/pdfs", exist_ok=True)
    
    # Create test PDFs
    create_test_pdf(
        "assets/pdfs/pmbok7.pdf",
        "PMBOK Guide 7th Edition - Test",
        [
            "This is a test PDF for the PMBOK Guide 7th Edition.",
            "Replace this with your actual PMBOK PDF file.",
            "",
            "Chapter 1: Introduction",
            "Chapter 2: The Environment in Which Projects Operate", 
            "Chapter 11: Project Risk Management",
            "",
            "This test file helps verify that PDF viewing works correctly."
        ]
    )
    
    create_test_pdf(
        "assets/pdfs/prince2.pdf", 
        "PRINCE2 2017 Edition - Test",
        [
            "This is a test PDF for PRINCE2 2017 Edition.",
            "Replace this with your actual PRINCE2 PDF file.",
            "",
            "Introduction",
            "Risk Theme",
            "Organization Theme",
            "",
            "This test file helps verify that PDF viewing works correctly."
        ]
    )
    
    create_test_pdf(
        "assets/pdfs/iso21500.pdf",
        "ISO 21500:2021 - Test", 
        [
            "This is a test PDF for ISO 21500:2021.",
            "Replace this with your actual ISO PDF file.",
            "",
            "1. Scope",
            "4.3.8 Risk",
            "4.3.6 Quality",
            "",
            "This test file helps verify that PDF viewing works correctly."
        ]
    )
    
    print("\n✅ Test PDF files created successfully!")
    print("Now run: flutter pub get && flutter run")
    
except ImportError:
    print("❌ reportlab not installed. Install with:")
    print("pip install reportlab")
    print("\nOr manually create PDF files and place them in assets/pdfs/")
