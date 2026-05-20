# LexSurv: Lexicostatistical Analysis App

LexSurv is a modern, responsive, and web-ready React application designed for comparative linguists and lexicostatisticians to organize language variety data, make cognitive/similarity judgments, and calculate lexicostatistical similarity matrices.

---

## 💡 Motivation & Creation

For decades, SIL’s **WordSurv** has been the standard desktop software used by linguists to perform lexicostatistical analysis, cognate judgment, and similarity percentage calculations. However, WordSurv (specifically versions up to WordSurv 6) is a legacy desktop application that is notoriously difficult or impossible to run on modern operating systems, particularly **macOS**. Running it on macOS typically requires setting up complex virtual machines, struggling with Wine/emulators, or attempting to install deprecated, insecure versions of Java runtimes.

**LexSurv** was created to fill this critical gap. Designed from the ground up to support macOS and other modern operating systems, LexSurv provides:
- **Zero-Install Web Access**: Runs inside any modern browser on any platform without local machine configuration.
- **Modern User Experience**: A clean, premium, grid-based interface built with React, Vite, and Tailwind CSS.
- **Robust Feature Parity**: Replicates the core conceptual data models of WordSurv—gloss dictionaries, variety wordlists, cognate grouping chars, exclusion rules, and similarity matrices—while offering enhanced data security through real-time auto-saving.

---

## 🛠️ Technology Stack

The application is structured as a single-page React app:
- **React**: Manages application UI, tab routing, and state.
- **Tailwind CSS**: Modern styling framework enabling premium look-and-feel and fluid layouts.
- **Vite**: Lightweight, fast build tool and hot-reloading dev server.
- **Lucide React**: Clean vector iconography.

---

## 🚀 Running the Application Locally

If you wish to run the project locally rather than hosting it on a web server:

### Prerequisites
- [Node.js](https://nodejs.org/) (v16 or higher recommended)
- `npm` or `yarn`

### Setup Instructions
1. Navigate to the project directory:
   ```bash
   cd lexicostats_app
   ```
2. Install the necessary dependencies:
   ```bash
   npm install
   ```
3. Boot up the Vite development server:
   ```bash
   npm run dev
   ```
4. Open the displayed local address (usually `http://localhost:5173`) in your web browser.

---

## 📖 Step-by-Step User Guide

LexSurv guides you through a five-stage lexicostatistical workflow, corresponding to the application's top navigation tabs: **Gloss Dictionary**, **Wordlists**, **Comparisons**, **Analysis**, and **Results Matrix**.

---

### 📂 Phase 1: Setup a Gloss Dictionary
A Gloss Dictionary defines the semantic placeholders (the list of concepts/words) you will elicit across your language varieties.

1. **Create or Select a Dictionary**: In the left sidebar of the **Gloss Dictionary** tab, enter a name and click the **+ (Plus)** button to initialize a dictionary.
2. **Add Glosses**:
   - **Manually**: Click **Add Gloss** in the top toolbar to insert a new row. You can specify:
     - **Primary Gloss**: The main elicitation prompt (e.g., *eye*).
     - **Secondary Gloss**: Additional context or clarification (e.g., *organ*).
     - **POS**: Part of speech (e.g., *N*, *V*).
     - **Field Tip**: Guidance for elicitation (e.g., *human only*).
   - **Predefined Presets**: Click the **Load Preset...** dropdown to instantly load standard comparative lists:
     - Swadesh 100
     - Swadesh 207
     - Leipzig-Jakarta 100
   - **CSV Import**: Import a custom list of glosses using the **Import CSV** button. The file should contain a header row and correspond to the following format:
     ```csv
     Primary Gloss,Secondary Gloss,POS,Field Tip
     eye,organ,N,human only
     water,liquid,N,running water
     ```

---

### 📝 Phase 2: Initialize a Survey & Enter Wordlists
A Survey contains your linguistic varieties and their phonetic transcriptions mapped directly to your linked Gloss Dictionary.

1. **Create a Survey**:
   - Select **+ Create New Survey** from the survey dropdown.
   - Enter a name, select a **Gloss Dictionary** to link it to, and click **New Survey**.
2. **Add Language Varieties**: 
   - Click **+ New** in the Varieties panel to create a language/dialect variety.
   - Fill in its metadata in the details panel: **Variety Name**, **Abbreviation** (for grid column headers), and **ISO 639-3 code**.
3. **Phonetic Transcription Entry**:
   - Click on any variety in the panel to open its transcription grid.
   - Type phonetic representations into the **Transcription** column.
   - **IPA Keyboard Palette**: Click the **IPA Palette** button in the main application header to toggle the fixed floating character helper. Use tabs (Vowels, Plosives, Fricatives, Nasals, and Other) to find and click IPA characters; they will automatically insert at your input cursor's position.
   - **Quick Navigation**: Pressing **`Enter`** in the transcription input box automatically saves the transcription and moves your cursor down to the next gloss transcription box.
   - Track progress visually using the amber progress indicator bars next to each variety.
4. **CSV Export / Import**:
   - You can export a blank or partially completed survey wordlist to CSV by clicking **Export Wordlist CSV**.
   - Fill out the CSV in external spreadsheet tools and re-import it using **Import Wordlist CSV**.
   - **Wordlist CSV Layout**:
     ```csv
     "Gloss","Variety A","Variety B"
     "eye","oŋo","oko"
     "water","maŋ","maŋ"
     ```

---

### 🔀 Phase 3: Make Lexical Comparisons & Judgments
Comparisons compile your variety transcriptions gloss-by-gloss so you can judge whether they are cognates, lexical similarities, or exact matches.

1. **Create a Comparison**:
   - Navigate to the **Comparisons** tab.
   - Provide a comparison name, select your **Survey**, and choose a comparison type:
     - **Similarity** (General lexicostatistical similarity)
     - **Cognacy** (Historical/etymological cognacy judgments)
     - **Identical** (Exact homophonous forms matching)
2. **Judge Gloss Groupings**:
   - Select a gloss from the left sidebar to load the judgment table.
   - A high-resolution **Magnification Panel** at the top displays the currently focused phonetic string to ease readability of IPA diacritics.
   - In the **Grouping** column, assign matching single character codes (such as `a`, `b`, `c`, etc.) to varieties that share a cognate class or lexical similarity grouping.
   - **Synchronic / Double Groupings**: If a variety exhibits multiple forms or synchronic variants belonging to separate grouping classes, separate the characters with a space (e.g. `a b` or `b c`).
3. **Handling Missing Data & Borrowings (Exclusions)**:
   - Check the **Exclude** checkbox for a variety if a form is a known historical borrowing, is unelicited (empty), or is otherwise unsuitable for the lexicostatistical calculation.
   - Excluded forms are removed from the denominator of comparisons containing that variety, preventing artificial skewing of the similarity percentages.
4. **Comparison Keyboard Shortcuts**:
   - **`Ctrl + Enter`**: Automatically save and jump to the next gloss in the dictionary list.
   - **`Ctrl + G`**: Automatically search forward and jump to the next gloss that has ungrouped, non-excluded varieties.
   - **`Ctrl + E`**: Exclude all varieties for the currently active gloss.

---

### 📊 Phase 4: Analyze Statistical Results
Once groupings are assigned, LexSurv compiles the mathematical comparisons into real-time similarity metrics.

Navigate to the **Analysis** tab to view the calculated grid matrix. You can toggle between three view types:
- **Percent**: The primary lexicostatistical score. Calculated as:
  $$\text{Percentage} = \text{round}\left( \frac{\text{Tally}}{\text{Total}} \times 100 \right)$$
- **Tally (Numerator)**: The number of glosses where the two varieties share an intersecting grouping character.
- **Total (Denominator)**: The total number of valid gloss comparisons (where both varieties have transcriptions, and neither variety is marked as excluded for that gloss).
- **Interactive Heatmap**: Cells are dynamically color-coded based on similarity thresholds:
  - 🟩 **Green (>= 75%)**: High lexicostatistical similarity / potential dialects of the same language.
  - 🦚 **Lime (50% - 74%)**: Medium-high similarity.
  - 🟨 **Yellow (25% - 49%)**: Medium-low similarity.
  - 🟥 **Red (< 25%)**: Low similarity / distinct language families or branches.

---

### 📐 Phase 5: Results Matrix & Data Portability
1. **Staircase Percentage Matrix**: Navigate to the **Results Matrix** tab to see a clean, triangular matrix display. This format is the standard layout for lexicostatistical tables in academic publications.
2. **Export Matrix CSV**: Click **Export to CSV** in this tab to write out the staircase percentage matrix directly to a CSV file. This CSV is ready to be loaded into spreadsheets, Python (Pandas), or R for phylogenetic tree generation.
3. **JSON Workspace Portability**:
   - LexSurv auto-saves your state to your browser's local storage debounced by 500ms. If you refresh or close the tab, your session is saved.
   - Under the header, use **Export Project** to download your entire workspace database—including all dictionaries, surveys, and comparisons—as a single structured `.json` backup file.
   - Load previous projects by choosing **Import Project** and uploading a previously exported JSON backup.

---

## 🤝 Contributing & Support

If you run into issues, have feature requests for phonological alignment utilities, or want to contribute to the codebase:
- Check out the main entry point code in [src/App.jsx](file:///Users/andykline/Documents/00_PhD_Active/lexicostats_app/src/App.jsx).
- Custom styling can be modified in [src/index.css](file:///Users/andykline/Documents/00_PhD_Active/lexicostats_app/src/index.css).
