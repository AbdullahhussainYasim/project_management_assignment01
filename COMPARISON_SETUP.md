# PDF Comparison System Setup Guide

This guide will help you set up an AI-powered PDF comparison system that extracts content, generates intelligent comparisons, and enables deep content search.

## 🚀 Quick Start

### 1. Install Python Dependencies

```bash
cd scripts
pip install -r requirements.txt
```

### 2. Get Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Set it as an environment variable:

**Windows:**
```cmd
set GEMINI_API_KEY=your_api_key_here
```

**Linux/Mac:**
```bash
export GEMINI_API_KEY=your_api_key_here
```

### 3. Add Your PDF Files

Place your PDF files in the `assets/pdfs/` directory:
```
assets/
  pdfs/
    ├── standard1.pdf
    ├── standard2.pdf
    └── standard3.pdf
```

### 4. Run the Complete Pipeline

```bash
cd scripts
python setup_and_run.py
```

This will:
- ✅ Install all dependencies
- ✅ Create necessary directories
- ✅ Extract content from PDFs
- ✅ Generate AI-powered comparisons
- ✅ Create searchable JSON files

## 📁 Generated Files

After running the pipeline, you'll have:

### Content Files
```
assets/
  extracted_content/
    ├── standard1_content.json
    ├── standard2_content.json
    └── standard3_content.json
```

### Comparison File
```
assets/
  ai_comparisons.json
```

## 🔍 Content Structure

### PDF Content JSON Structure
```json
{
  "file_name": "standard1.pdf",
  "total_pages": 150,
  "sections": [
    {
      "heading": "Security Requirements",
      "level": 1,
      "page_start": 10,
      "page_end": 15,
      "content": "Full section content...",
      "keywords": ["security", "authentication", "access"]
    }
  ],
  "full_text_by_page": {
    "1": "Page 1 full text...",
    "2": "Page 2 full text..."
  },
  "headings": [
    {
      "text": "Security Requirements",
      "page": 10,
      "level": 1
    }
  ]
}
```

### AI Comparison JSON Structure
```json
{
  "generated_at": "2024-01-15 10:30:00",
  "standards": ["Standard 1", "Standard 2"],
  "topics": [
    {
      "id": "security_requirements",
      "title": "Security Requirements",
      "description": "Security measures and authentication requirements",
      "keywords": ["security", "authentication", "access"],
      "references": {
        "Standard 1": {
          "sections": [
            {
              "heading": "Authentication Methods",
              "page": 15,
              "content_preview": "This section covers...",
              "relevance_score": 8.5
            }
          ]
        }
      },
      "ai_comparison": {
        "summary": "Both standards emphasize security...",
        "similarities": [
          "Both require multi-factor authentication",
          "Both mandate encryption at rest"
        ],
        "differences": [
          {
            "aspect": "Password complexity",
            "standards": {
              "Standard 1": "Requires 12+ characters",
              "Standard 2": "Requires 8+ characters"
            }
          }
        ],
        "recommendations": "Use Standard 1 for high-security environments..."
      }
    }
  ]
}
```

## 🔧 Customization

### Modify Heading Detection

Edit `pdf_content_extractor.py` to adjust heading patterns:

```python
self.heading_patterns = [
    r'^(\d+\.?\d*\.?\d*)\s+([A-Z][^.]*)',  # Numbered headings
    r'^([A-Z][A-Z\s]{10,})',  # ALL CAPS headings
    # Add your custom patterns here
]
```

### Adjust AI Prompts

Edit `ai_comparison_generator.py` to customize AI prompts:

```python
prompt = f"""
Your custom prompt for topic identification...
"""
```

### Configure Search Sensitivity

Edit `content_search_provider.dart` to adjust search scoring:

```dart
// Heading matches (higher weight)
if (headingLower.contains(word)) {
  score += 3.0; // Adjust this weight
}
```

## 🔍 Flutter Integration

### 1. Update Your Search Page

```dart
import '../core/providers/content_search_provider.dart';

class SearchPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(searchResultsProvider(query));
    
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final result = searchResults[index];
        return ListTile(
          title: Text(result.heading),
          subtitle: Text(result.contentPreview),
          trailing: Text('Page ${result.page}'),
          onTap: () {
            // Navigate to PDF viewer with specific page
            context.push('/pdf/${result.standardName}?page=${result.page}');
          },
        );
      },
    );
  }
}
```

### 2. Update Comparison View

The comparison view will automatically use the new AI-generated comparisons when you load the `ai_comparisons.json` file into your topics provider.

### 3. Add Content Search

```dart
final contentSearch = ref.watch(contentSearchProvider);

contentSearch.when(
  data: (content) => Text('Loaded ${content.length} standards'),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

## 🎯 Features

### ✅ What This System Provides

1. **Deep Content Extraction**
   - Extracts all text from PDFs
   - Identifies headings and sections
   - Generates keywords automatically

2. **AI-Powered Comparisons**
   - Uses Google Gemini to analyze content
   - Identifies similarities and differences
   - Provides actionable recommendations

3. **Advanced Search**
   - Searches through full content, not just headings
   - Relevance scoring
   - Context-aware previews

4. **Page-Level Navigation**
   - Click any result to jump to specific page
   - Maintains context and relevance

### 🔄 Workflow

1. **Extract** → Python scripts extract structured content from PDFs
2. **Analyze** → AI analyzes content and generates comparisons
3. **Search** → Flutter app provides deep content search
4. **Navigate** → Users click to jump to specific pages

## 🐛 Troubleshooting

### Common Issues

1. **"No PDF files found"**
   - Ensure PDFs are in `assets/pdfs/` directory
   - Check file permissions

2. **"Gemini API key not set"**
   - Verify environment variable is set correctly
   - Restart terminal/command prompt after setting

3. **"PDF extraction failed"**
   - Install PyMuPDF: `pip install PyMuPDF`
   - Check PDF file integrity

4. **"AI comparison generation failed"**
   - Check API key validity
   - Verify internet connection
   - Check API quota limits

### Debug Mode

Add debug logging to see what's happening:

```python
import logging
logging.basicConfig(level=logging.DEBUG)
```

## 📈 Performance Tips

1. **Large PDFs**: Process in batches to avoid memory issues
2. **API Limits**: Add delays between API calls if needed
3. **Search Speed**: Index content for faster searches
4. **Storage**: Compress JSON files if they become too large

## 🔄 Updates

To update comparisons with new content:

1. Add new PDFs to `assets/pdfs/`
2. Run `python setup_and_run.py` again
3. Restart your Flutter app to load new data

This system provides a comprehensive foundation for intelligent PDF comparison and search functionality!