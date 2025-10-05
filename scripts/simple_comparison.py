#!/usr/bin/env python3
"""
Simple AI Comparison Generator
A more robust version with better error handling
"""

import json
import os
import time
from pathlib import Path

def load_content_files():
    """Load all extracted content files"""
    content_dir = Path("assets/extracted_content")
    if not content_dir.exists():
        print("Error: No extracted content found. Run simple_extractor.py first.")
        return []
    
    content_files = list(content_dir.glob("*_content.json"))
    if not content_files:
        print("Error: No content files found. Run simple_extractor.py first.")
        return []
    
    all_content = []
    for file_path in content_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = json.load(f)
                all_content.append(content)
                print(f"✓ Loaded: {file_path.name}")
        except Exception as e:
            print(f"✗ Error loading {file_path.name}: {e}")
    
    return all_content

def generate_simple_topics(all_content):
    """Generate topics without AI (fallback)"""
    print("Generating topics from content...")
    
    # Collect all headings
    all_headings = []
    for content in all_content:
        for heading in content.get('headings', []):
            all_headings.append(heading['text'].lower())
    
    # Find common keywords
    common_keywords = {}
    for content in all_content:
        for section in content.get('sections', []):
            for keyword in section.get('keywords', []):
                common_keywords[keyword] = common_keywords.get(keyword, 0) + 1
    
    # Create topics based on common keywords
    topics = []
    top_keywords = sorted(common_keywords.items(), key=lambda x: x[1], reverse=True)[:10]
    
    for i, (keyword, count) in enumerate(top_keywords):
        topics.append({
            'id': f'topic_{i+1}',
            'title': keyword.title(),
            'description': f'Content related to {keyword}',
            'keywords': [keyword],
            'references': {}
        })
    
    return topics

def generate_with_ai(all_content):
    """Generate comparisons using AI"""
    try:
        import google.generativeai as genai
        
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            print("Warning: GEMINI_API_KEY not set. Using simple topic generation.")
            return generate_simple_topics(all_content)
        
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-pro')
        
        # Create a simple prompt
        headings_text = ""
        for content in all_content:
            headings_text += f"\n{content['file_name']}:\n"
            for heading in content.get('headings', [])[:10]:  # Limit to avoid token limits
                headings_text += f"  - {heading['text']}\n"
        
        prompt = f"""
        Analyze these document headings and identify 5 common topics for comparison:
        
        {headings_text}
        
        Return a JSON array with this structure:
        [
          {{
            "title": "Topic Name",
            "description": "Brief description",
            "keywords": ["keyword1", "keyword2"]
          }}
        ]
        """
        
        print("Generating topics with AI...")
        response = model.generate_content(prompt)
        
        # Try to extract JSON from response
        response_text = response.text
        start_idx = response_text.find('[')
        end_idx = response_text.rfind(']') + 1
        
        if start_idx != -1 and end_idx != -1:
            json_str = response_text[start_idx:end_idx]
            topics = json.loads(json_str)
            print(f"✓ Generated {len(topics)} topics with AI")
            return topics
        else:
            print("Could not parse AI response, using simple generation")
            return generate_simple_topics(all_content)
            
    except ImportError:
        print("google-generativeai not installed. Using simple topic generation.")
        return generate_simple_topics(all_content)
    except Exception as e:
        print(f"AI generation failed: {e}. Using simple topic generation.")
        return generate_simple_topics(all_content)

def create_comparison_data(topics, all_content):
    """Create the final comparison data structure"""
    comparison_data = {
        'generated_at': time.strftime("%Y-%m-%d %H:%M:%S"),
        'standards': [content['file_name'].replace('.pdf', '') for content in all_content],
        'topics': []
    }
    
    for topic in topics:
        topic_data = {
            'id': topic.get('id', topic['title'].lower().replace(' ', '_')),
            'title': topic['title'],
            'description': topic['description'],
            'keywords': topic.get('keywords', []),
            'references': {},
            'ai_comparison': {
                'summary': f"Comparison of {topic['title']} across standards",
                'similarities': ["Both standards address this topic"],
                'differences': [],
                'recommendations': "Compare specific implementations"
            }
        }
        
        # Find relevant sections in each standard
        for content in all_content:
            standard_name = content['file_name'].replace('.pdf', '')
            relevant_sections = []
            
            # Simple relevance matching
            for section in content.get('sections', []):
                section_text = (section.get('heading', '') + ' ' + 
                              ' '.join(section.get('keywords', []))).lower()
                
                # Check if any topic keywords appear in section
                for keyword in topic.get('keywords', []):
                    if keyword.lower() in section_text:
                        relevant_sections.append({
                            'heading': section.get('heading', ''),
                            'page': section.get('page_start', 1),
                            'content_preview': section.get('content', '')[:200] + "...",
                            'relevance_score': 1.0
                        })
                        break
            
            if relevant_sections:
                topic_data['references'][standard_name] = {
                    'sections': relevant_sections[:3],  # Top 3 sections
                    'pages': [s['page'] for s in relevant_sections[:3]]
                }
        
        # Only add topics that have references in multiple standards
        if len(topic_data['references']) >= 2:
            comparison_data['topics'].append(topic_data)
    
    return comparison_data

def main():
    """Main function"""
    print("🤖 Simple AI Comparison Generator")
    print("=" * 40)
    
    # Load content files
    all_content = load_content_files()
    if len(all_content) < 2:
        print("Error: Need at least 2 content files for comparison")
        return
    
    # Generate topics
    topics = generate_with_ai(all_content)
    if not topics:
        print("Error: Could not generate topics")
        return
    
    # Create comparison data
    comparison_data = create_comparison_data(topics, all_content)
    
    # Save results
    output_file = Path("assets/ai_comparisons.json")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(comparison_data, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Generated {len(comparison_data['topics'])} comparisons")
    print(f"✅ Saved to: {output_file}")

if __name__ == "__main__":
    main()