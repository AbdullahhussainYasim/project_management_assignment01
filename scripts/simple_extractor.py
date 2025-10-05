#!/usr/bin/env python3
"""
Simple PDF Content Extractor
A more robust version with better error handling
"""

import json
import os
import re
from pathlib import Path

def extract_text_from_pdf(pdf_path):
    """Extract text from PDF using available library"""
    try:
        import fitz  # PyMuPDF
        doc = fitz.open(pdf_path)
        full_text = {}
        total_pages = len(doc)  # Get page count before closing
        
        for page_num in range(total_pages):
            page = doc[page_num]
            text = page.get_text()
            full_text[page_num + 1] = text
        
        doc.close()
        return full_text, total_pages
        
    except ImportError:
        print("PyMuPDF not available, trying PyPDF2...")
        try:
            import PyPDF2
            with open(pdf_path, 'rb') as file:
                reader = PyPDF2.PdfReader(file)
                full_text = {}
                
                for page_num in range(len(reader.pages)):
                    page = reader.pages[page_num]
                    text = page.extract_text()
                    full_text[page_num + 1] = text
                
                return full_text, len(reader.pages)
        except ImportError:
            print("No PDF library available. Please install PyMuPDF or PyPDF2")
            return None, 0
    except Exception as e:
        print(f"Error reading PDF {pdf_path}: {e}")
        return None, 0

def find_headings(text):
    """Simple heading detection"""
    headings = []
    lines = text.split('\n')
    
    for line_num, line in enumerate(lines):
        line = line.strip()
        if not line:
            continue
            
        # Simple heading patterns
        if (len(line) < 100 and 
            (line.isupper() or 
             re.match(r'^\d+\.', line) or 
             re.match(r'^[A-Z][a-z]+.*:$', line))):
            headings.append({
                'text': line,
                'line_number': line_num
            })
    
    return headings

def extract_keywords(text):
    """Simple keyword extraction"""
    # Remove common words and extract meaningful terms
    words = re.findall(r'\b[A-Za-z]{4,}\b', text.lower())
    
    stop_words = {
        'this', 'that', 'with', 'have', 'will', 'from', 'they', 'been',
        'were', 'said', 'each', 'which', 'their', 'time', 'would', 'there',
        'could', 'other', 'more', 'very', 'what', 'know', 'just', 'first',
        'into', 'over', 'think', 'also', 'your', 'work', 'life', 'only',
        'can', 'still', 'should', 'after', 'being', 'now', 'made', 'before',
        'must', 'shall', 'requirements', 'standard', 'specification'
    }
    
    keywords = [word for word in set(words) if word not in stop_words and len(word) > 3]
    return sorted(keywords)[:15]  # Top 15 keywords

def process_pdf(pdf_path):
    """Process a single PDF file"""
    print(f"Processing: {os.path.basename(pdf_path)}")
    
    # Extract text
    full_text, total_pages = extract_text_from_pdf(pdf_path)
    if not full_text:
        return None
    
    # Process each page
    sections = []
    all_headings = []
    
    for page_num, text in full_text.items():
        if not text.strip():
            continue
            
        # Find headings on this page
        headings = find_headings(text)
        
        for heading in headings:
            all_headings.append({
                'text': heading['text'],
                'page': page_num,
                'level': 1  # Simple level assignment
            })
            
            # Create a section for each heading
            sections.append({
                'heading': heading['text'],
                'level': 1,
                'page_start': page_num,
                'page_end': page_num,
                'content': text[:500] + "..." if len(text) > 500 else text,
                'keywords': extract_keywords(text)
            })
    
    # Create content structure
    content = {
        'file_name': os.path.basename(pdf_path),
        'total_pages': total_pages,
        'sections': sections,
        'full_text_by_page': {str(k): v for k, v in full_text.items()},
        'headings': all_headings
    }
    
    return content

def main():
    """Main processing function"""
    # Check multiple possible PDF directory locations
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
                print(f"Found PDF directory: {pdf_dir}")
                break
    
    if not pdf_files:
        print(f"No PDF files found in any of these locations:")
        for path in possible_paths:
            print(f"  - {path.absolute()}")
        print("Please add your PDF files to one of these directories")
        return
    
    # Create output directory relative to where PDFs were found
    if pdf_dir == Path("../assets/pdfs"):
        output_dir = Path("../assets/extracted_content")
    else:
        output_dir = Path("assets/extracted_content")
    output_dir.mkdir(parents=True, exist_ok=True)
    print(f"Output directory: {output_dir}")
    
    # Process each PDF
    for pdf_file in pdf_files:
        try:
            content = process_pdf(pdf_file)
            if content:
                # Save to JSON
                output_file = output_dir / f"{pdf_file.stem}_content.json"
                with open(output_file, 'w', encoding='utf-8') as f:
                    json.dump(content, f, indent=2, ensure_ascii=False)
                print(f"✓ Saved: {output_file}")
            else:
                print(f"✗ Failed to process: {pdf_file.name}")
        except Exception as e:
            print(f"✗ Error processing {pdf_file.name}: {e}")
    
    print(f"\n✅ Processing complete! Check {output_dir} for results.")

if __name__ == "__main__":
    main()