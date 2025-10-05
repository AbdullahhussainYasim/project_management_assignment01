# Project Management (Assignment - 1)
## Group#7 (Section B)
- **BSCS23008**: Abdullah Hussain Yasim
- **BSCS23038**: Muhammad Asharib
- **BSCS23077**: Abuhurairah Faheem

# Project Management Standards Comparison App

A comprehensive Flutter application for comparing project management standards (PMBOK 7, PRINCE2, ISO 21500/21502) with side-by-side analysis, PDF viewing, and intelligent insights.

## 🚀 Features

### Core Functionality
- **PDF Viewer**: View and navigate through standard documents with search functionality
- **Side-by-Side Comparison**: Compare topics across multiple standards simultaneously  
- **Deep Linking**: Jump directly to specific pages in PDFs based on topic references
- **Search Engine**: Find topics and keywords across all standards
- **Bookmarks**: Save important sections for quick access
- **Insights Dashboard**: View similarities, differences, and unique points between standards

### Technical Features
- **Modular Architecture**: Clean separation of concerns with feature-based structure
- **State Management**: Riverpod for reactive state management
- **Responsive Design**: Adaptive UI for mobile, tablet, and desktop
- **Offline Support**: Local JSON data with caching
- **Material 3 Design**: Modern UI following Material Design guidelines

## 📱 Screenshots

### Home Screen
- Overview of available standards
- Quick actions for comparison and search
- Recent topics and bookmarks

### PDF Viewer
- Full-featured PDF viewing with Syncfusion PDF Viewer
- Search within documents
- Table of contents navigation
- Bookmark pages

### Comparison View
- Side-by-side topic comparison
- Standard-specific information cards
- Direct links to PDF pages
- Mobile-responsive layout

### Insights Dashboard
- Similarities, differences, and unique points
- Filterable insights
- Detailed analysis cards
- Statistical overview

## 🛠 Installation & Setup

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Git

### Dependencies
```yaml
dependencies:
  # UI & Navigation
  go_router: ^14.2.7
  
  # PDF & Document Handling
  syncfusion_flutter_pdfviewer: ^26.2.14
  
  # State Management
  flutter_riverpod: ^2.5.1
  
  # Storage & Data
  shared_preferences: ^2.3.2
  path_provider: ^2.1.4
  
  # HTTP & JSON
  http: ^1.2.2
  
  # UI Components
  flutter_staggered_grid_view: ^0.7.0
```

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd project_management
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add PDF files**
   Place your PDF files in the `assets/pdfs/` directory:
   - `pmbok7.pdf` - PMBOK Guide 7th Edition
   - `prince2.pdf` - PRINCE2 2017 Edition  
   - `iso21500.pdf` - ISO 21500:2021
   - `iso21502.pdf` - ISO 21502:2020 (optional)

4. **Run the application**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── core/
│   ├── data/
│   │   └── repositories/
│   │       └── standards_repository.dart
│   ├── models/
│   │   ├── standard.dart
│   │   ├── topic.dart
│   │   └── comparison.dart
│   ├── providers/
│   │   └── standards_provider.dart
│   ├── router/
│   │   └── app_router.dart
│   └── theme/
│       └── app_theme.dart
├── features/
│   ├── home/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── widgets/
│   ├── pdf_viewer/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── widgets/
│   ├── comparison/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── widgets/
│   ├── search/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── widgets/
│   └── insights/
│       └── presentation/
│           ├── pages/
│           └── widgets/
└── main.dart

assets/
├── data/
│   ├── standards.json
│   ├── topics.json
│   └── insights.json
├── pdfs/
│   ├── pmbok7.pdf
│   ├── prince2.pdf
│   └── iso21500.pdf
└── images/
```

## 📊 Data Structure

### Deep Linking JSON Format

The app uses JSON files to map topics to specific pages in PDFs:

```json
{
  "id": "risk_management",
  "title": "Risk Management", 
  "description": "Identifying, analyzing, and responding to project risks",
  "keywords": ["risk", "uncertainty", "threat", "opportunity"],
  "references": {
    "pmbok": {
      "page": 120,
      "section": "11. Project Risk Management",
      "subsection": "11.1 Plan Risk Management",
      "excerpt": "Risk management includes the processes..."
    },
    "prince2": {
      "page": 88,
      "section": "Risk Theme",
      "subsection": "Risk Management Approach", 
      "excerpt": "The purpose of the Risk theme is to identify..."
    },
    "iso21500": {
      "page": 54,
      "section": "4.3.8 Risk",
      "subsection": "Risk Management Process",
      "excerpt": "Risk management should be an integral part..."
    }
  }
}
```

### Insights JSON Format

```json
{
  "topicId": "risk_management",
  "title": "Risk Management Comparison",
  "similarities": [
    "All standards require systematic risk identification",
    "Risk assessment and analysis are fundamental"
  ],
  "differences": [
    {
      "aspect": "Risk Analysis Approach",
      "descriptions": {
        "pmbok": "Uses qualitative and quantitative analysis",
        "prince2": "Focuses on risk tolerance and appetite",
        "iso21500": "Emphasizes systematic risk processes"
      }
    }
  ],
  "uniquePoints": {
    "pmbok": ["Monte Carlo simulation", "Expected Monetary Value"],
    "prince2": ["Risk tolerance", "Risk appetite"],
    "iso21500": ["Risk governance", "Stakeholder risk perception"]
  }
}
```

## 🔧 How to Get JSON Files for Deep Linking

### Method 1: Manual Creation
1. **Analyze PDF Structure**: Open each standard PDF and note chapter/section structure
2. **Identify Common Topics**: List topics that appear across multiple standards
3. **Map Page Numbers**: For each topic, find the relevant page numbers in each standard
4. **Create JSON Entries**: Use the format shown above

### Method 2: Automated Extraction (Advanced)
```python
# Example Python script for PDF text extraction
import PyPDF2
import json

def extract_toc_from_pdf(pdf_path):
    with open(pdf_path, 'rb') as file:
        reader = PyPDF2.PdfReader(file)
        # Extract table of contents
        # Map sections to page numbers
        # Return structured data
    pass

# Process each standard
standards = ['pmbok7.pdf', 'prince2.pdf', 'iso21500.pdf']
for standard in standards:
    toc_data = extract_toc_from_pdf(f'assets/pdfs/{standard}')
    # Process and map to common topics
```

### Method 3: AI-Assisted Generation
Use AI tools like ChatGPT or Claude to help create mappings:

1. **Provide PDF excerpts** of table of contents
2. **Ask for topic mapping** across standards  
3. **Request JSON format** output
4. **Validate and refine** the generated mappings

### Sample Topics to Map
- Risk Management
- Stakeholder Management  
- Quality Management
- Scope Management
- Schedule Management
- Cost Management
- Resource Management
- Communication Management
- Procurement Management
- Integration Management

## 🎯 Usage Examples

### Navigate to Specific PDF Page
```dart
// Jump to Risk Management section in PMBOK
context.push('/pdf/pmbok?page=120');

// Open comparison for specific topic
context.push('/comparison/risk_management');
```

### Search Functionality
```dart
// Search across all topics
ref.read(searchQueryProvider.notifier).state = 'risk management';

// Filter results
final results = await repository.searchTopics('stakeholder');
```

### Bookmark Management
```dart
// Add bookmark
ref.read(bookmarksProvider.notifier).addBookmark('risk_management');

// Check if bookmarked
final isBookmarked = ref.read(bookmarksProvider.notifier).isBookmarked('risk_management');
```

## 🚀 Advanced Features

### Custom PDF Integration
To add new standards:

1. **Add PDF file** to `assets/pdfs/`
2. **Update standards.json** with new standard info
3. **Add topics mapping** in `topics.json`
4. **Create insights** in `insights.json`
5. **Update StandardType enum** in `standard.dart`

### AI Integration (Optional)
For dynamic insights generation:

```dart
// Example Gemini API integration
class AIInsightsService {
  Future<ComparisonInsight> generateInsight(Topic topic) async {
    // Call Gemini API with topic data
    // Parse response into ComparisonInsight
    // Return structured insights
  }
}
```

### Tailoring Feature (Future Enhancement)
```dart
class ProjectTailoringService {
  List<String> getTailoredRecommendations({
    required ProjectType type,
    required List<String> selectedTopics,
  }) {
    // Rule-based or AI-generated recommendations
    // Based on project characteristics
  }
}
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Syncfusion** for the excellent PDF viewer component
- **Riverpod** for reactive state management
- **Material Design** for UI guidelines
- **Flutter Team** for the amazing framework

## 📞 Support

For questions or support:
- Create an issue on GitHub
- Check the documentation
- Review the code examples

---

**Happy Coding! 🚀**