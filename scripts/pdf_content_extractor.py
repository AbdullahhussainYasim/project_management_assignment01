#!/usr/bin/env python3
"""
PDF Content Extractor for Standards Comparison
Extracts headings, content, and page numbers from PDF files
"""

import json
import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Any

# Try to import required libraries with error handling
try:
    import fitz  # PyMuPDF - better for text extraction
    HAS_PYMUPDF = True
except ImportError:
    print("Warning: PyMuPDF not found. Install with: pip install PyMuPDF")
    HAS_PYMUPDF = False

try:
    import PyPDF2
    HAS_PYPDF2 = True
except ImportError:
    print("Warning: PyPDF2 not found. Install with: pip install PyPDF2")
    HAS_PYPDF2 = False

if not HAS_PYMUPDF and not HAS_PYPDF2:
    print("Error: No PDF processing library available. Please install PyMuPDF or PyPDF2")
    sys.exit(1)

class PDFContentExtractor:
    def __init__(self):
        self.heading_patterns = [
            r'^(\d+\.?\d*\.?\d*)\s+([A-Z][^.]*)',  # Numbered headings
            r'^([A-Z][A-Z\s]{10,})',  # ALL CAPS headings
            r'^(Chapter|Section|Part)\s+(\d+)',  # Chapter/Section patterns
            r'^([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*):',  # Title case with colon
        ]
    
    def extract_pdf_content(self, pdf_path: str):
        """Extract structured content from PDF"""
        if not os.path.exists(pdf_path):
            print(f"Error: PDF file not found: {pdf_path}")
            return None
            
        try:
            if HAS_PYMUPDF:
                return self._extract_with_pymupdf(pdf_path)
            elif HAS_PYPDF2:
                return self._extract_with_pypdf2(pdf_path)
            else:
                print("Error: No PDF processing library available")
                return None
        except Exception as e:
            print(f"Error extracting content from {pdf_path}: {e}")
            return None
    
    def _extract_with_pymupdf(self, pdf_path: str):
        """Extract content using PyMuPDF"""
        doc = fitz.open(pdf_path)
        content = {
            "file_name": os.path.basename(pdf_path),
            "total_pages": len(doc),
            "sections": [],
            "full_text_by_page": {},
            "headings": []
        }
        
        current_section = None
        
        for page_num in range(len(doc)):
            page = doc[page_num]
            text = page.get_text()
            
            # Store full text for each page
            content["full_text_by_page"][page_num + 1] = text
            
            # Extract headings and sections
            lines = text.split('\n')
            for line_num, line in enumerate(lines):
                line = line.strip()
                if not line:
                    continue
                
                # Check if line is a heading
                heading_info = self._identify_heading(line)
                if heading_info:
                    # Save previous section if exists
                    if current_section:
                        content["sections"].append(current_section)
                    
                    # Start new section
                    current_section = {
                        "heading": heading_info["text"],
                        "level": heading_info["level"],
                        "page_start": page_num + 1,
                        "page_end": page_num + 1,
                        "content": "",
                        "keywords": []
                    }
                    
                    content["headings"].append({
                        "text": heading_info["text"],
                        "page": page_num + 1,
                        "level": heading_info["level"]
                    })
                
                elif current_section:
                    # Add content to current section
                    current_section["content"] += line + " "
                    current_section["page_end"] = page_num + 1
        
        # Add last section
        if current_section:
            content["sections"].append(current_section)
        
        # Extract keywords for each section
        for section in content["sections"]:
            section["keywords"] = self._extract_keywords(section["content"])
        
        doc.close()
        return content
    
    def _extract_with_pypdf2(self, pdf_path: str):
        """Extract content using PyPDF2 (fallback method)"""
        try:
            with open(pdf_path, 'rb') as file:
                reader = PyPDF2.PdfReader(file)
                content = {
                    "file_name": os.path.basename(pdf_path),
                    "total_pages": len(reader.pages),
                    "sections": [],
                    "full_text_by_page": {},
                    "headings": []
                }
                
                for page_num in range(len(reader.pages)):
                    page = reader.pages[page_num]
                    text = page.extract_text()
                    content["full_text_by_page"][page_num + 1] = text
                    
                    # Simple heading extraction for PyPDF2
                    lines = text.split('\n')
                    for line in lines:
                        line = line.strip()
                        if line and len(line) < 100 and (line.isupper() or re.match(r'^\d+\.', line)):
                            content["headings"].append({
                                "text": line,
                                "page": page_num + 1,
                                "level": 1
                            })
                
                return content
        except Exception as e:
            print(f"Error with PyPDF2: {e}")
            return None
    
    def _identify_heading(self, line: str) -> Dict[str, Any]:
        """Identify if a line is a heading and determine its level"""
        for i, pattern in enumerate(self.heading_patterns):
            match = re.match(pattern, line)
            if match:
                return {
                    "text": line,
                    "level": i + 1,
                    "pattern_matched": pattern
                }
        
        # Additional heuristics
        if len(line) < 100 and line.isupper() and len(line.split()) > 1:
            return {"text": line, "level": 2, "pattern_matched": "uppercase"}
        
        if len(line) < 80 and line.endswith(':') and not line.startswith(' '):
            return {"text": line, "level": 3, "pattern_matched": "colon_ending"}
        
        return None
    
    def _extract_keywords(self, text: str) -> List[str]:
        """Extract important keywords from text"""
        # Simple keyword extraction - can be enhanced with NLP
        words = re.findall(r'\b[A-Za-z]{4,}\b', text.lower())
        
        # Filter common words
        stop_words = {
            'this', 'that', 'with', 'have', 'will', 'from', 'they', 'been',
            'were', 'said', 'each', 'which', 'their', 'time', 'would', 'there',
            'could', 'other', 'more', 'very', 'what', 'know', 'just', 'first',
            'into', 'over', 'think', 'also', 'your', 'work', 'life', 'only',
            'can', 'still', 'should', 'after', 'being', 'now', 'made', 'before'
        }
        
        keywords = [word for word in set(words) if word not in stop_words and len(word) > 3]
        return sorted(keywords)[:20]  # Top 20 keywords

def main():
    """Main function to process PDF files"""
    extractor = PDFContentExtractor()
    
    # Define paths
    pdf_directory = "assets/pdfs"  # Adjust path as needed
    output_directory = "assets/extracted_content"
    
    # Create output directory
    Path(output_directory).mkdir(parents=True, exist_ok=True)
    
    # Process all PDF files
    pdf_files = list(Path(pdf_directory).glob("*.pdf"))
    
    for pdf_file in pdf_files:
        print(f"Processing: {pdf_file.name}")
        
        content = extractor.extract_pdf_content(str(pdf_file))
        if content:
            # Save extracted content as JSON
            output_file = Path(output_directory) / f"{pdf_file.stem}_content.json"
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(content, f, indent=2, ensure_ascii=False)
            
            print(f"✓ Extracted content saved to: {output_file}")
        else:
            print(f"✗ Failed to extract content from: {pdf_file.name}")

if __name__ == "__main__":
    main()