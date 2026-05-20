import React, { useState, useEffect, useRef, useCallback } from 'react';
import { Book, List, SplitSquareVertical, LineChart, Table, Plus, Trash2, Upload, Download, Save, FolderOpen, Type, X } from 'lucide-react';

export const SWADESH_100 = [
    "I", "you (singular)", "we", "this", "that", "who", "what", "not", "all", "many",
    "one", "two", "big", "long", "small", "woman", "man", "person", "fish", "bird",
    "dog", "louse", "tree", "seed", "leaf", "root", "bark", "skin", "flesh", "blood",
    "bone", "grease", "egg", "horn", "tail", "feather", "hair", "head", "ear", "eye",
    "nose", "mouth", "tooth", "tongue", "fingernail", "foot", "knee", "hand", "belly", "neck",
    "breast", "heart", "liver", "drink", "eat", "bite", "see", "hear", "know", "sleep",
    "die", "kill", "swim", "fly", "walk", "come", "lie", "sit", "stand", "give",
    "say", "sun", "moon", "star", "water", "rain", "stone", "sand", "earth", "cloud",
    "smoke", "fire", "ash", "burn", "path", "mountain", "red", "green", "yellow", "white",
    "black", "night", "hot", "cold", "full", "new", "good", "round", "dry", "name"
];

export const SWADESH_207 = [
    ...SWADESH_100,
    "he/she", "they", "thou", "ye", "here", "there", "where", "when", "how", "other",
    "some", "few", "three", "four", "five", "heavy", "short", "narrow", "wide", "thick",
    "thin", "child", "wife", "husband", "mother", "father", "animal", "snake", "worm", "forest",
    "stick", "fruit", "flower", "grass", "rope", "meat", "leg", "back", "navel", "intestines",
    "spit", "vomit", "blow", "breathe", "laugh", "cry", "fear", "think", "smell", "fall",
    "turn", "wash", "wipe", "pull", "push", "throw", "tie", "sew", "count", "sing",
    "play", "float", "flow", "freeze", "swell", "split", "scratch", "dig", "squeeze", "wring",
    "rub", "dirty", "straight", "wet", "right", "left", "at", "in", "with", "and",
    "if", "because", "near", "far", "smooth", "heavy", "wet", "dry", "sharp", "dull",
    "warm", "cold", "old", "bad", "right", "left", "straight", "crooked", "year", "day",
    "dust", "ice", "salt"
];

export const LEIPZIG_JAKARTA_100 = [
    "fire", "water", "run", "eye", "bitter", "leg/foot", "blood", "bone", "name", "dog",
    "tooth", "hear", "you (sg.)", "knee", "leaf", "know", "meat/flesh", "come", "louse", "hair",
    "liver", "breast", "sun", "night", "eat", "moon", "go", "thigh", "stone", "tongue",
    "I", "ash", "he/she/it", "drink", "laugh", "path/road", "sand", "bite", "wing", "fly",
    "star", "egg", "hide", "tail", "earth/soil", "navel", "root", "fish", "see", "tree",
    "hand", "neck", "wind", "child", "skin", "stand", "we", "give", "house", "who",
    "smoke", "ant", "mouth", "take", "bite", "tear", "burn", "wood", "spit", "tie",
    "salt", "rain", "yesterday", "die", "two", "blow", "kill", "one", "what", "weep/cry",
    "this", "bite", "fly", "not", "say", "where", "big", "bird", "do/make", "person/human",
    "good", "long", "new", "black", "head", "heavy", "shadow", "all", "old", "white"
];

export const IPA_PALETTE = {
    Vowels: ['i', 'y', 'ɨ', 'ʉ', 'ɯ', 'u', 'ɪ', 'ʏ', 'ʊ', 'e', 'ø', 'ɘ', 'ɵ', 'ɤ', 'o', 'ə', 'ɛ', 'œ', 'ɜ', 'ɞ', 'ʌ', 'ɔ', 'æ', 'ɐ', 'a', 'ɶ', 'ä', 'ɑ', 'ɒ'],
    Plosives: ['p', 'b', 't', 'd', 'ʈ', 'ɖ', 'c', 'ɟ', 'k', 'ɡ', 'q', 'ɢ', 'ʔ'],
    Fricatives: ['ɸ', 'β', 'f', 'v', 'θ', 'ð', 's', 'z', 'ʃ', 'ʒ', 'ʂ', 'ʐ', 'ç', 'ʝ', 'x', 'ɣ', 'χ', 'ʁ', 'ħ', 'ʕ', 'h', 'ɦ'],
    Nasals: ['m', 'ɱ', 'n', 'ɳ', 'ɲ', 'ŋ', 'ɴ'],
    Other: ['ɾ', 'r', 'ʀ', 'ʋ', 'ɹ', 'ɻ', 'j', 'ɰ', 'l', 'ɭ', 'ʎ', 'ʟ', 'w', 'ɥ', 'ɓ', 'ɗ', 'ʄ', 'ɠ', 'ʛ', 'ʘ', 'ǀ', 'ǃ', 'ǂ', 'ǁ', 'ʰ', 'ʷ', 'ʲ', 'ˠ', 'ˤ', 'ⁿ', 'ˡ', 'ˈ', 'ˌ', 'ː', 'ˑ', '˘', '.', '|', '‖', '‿', '͡', '͜']
};

export default function App() {
    const [glossDictionaries, setGlossDictionaries] = useState([]);
    const [surveys, setSurveys] = useState([]);
    const [comparisons, setComparisons] = useState([]);

    // Persistence & Global UI State
    const [savedSessionStatus, setSavedSessionStatus] = useState('checking'); // 'checking' | 'found' | 'none'
    const [lastSavedTime, setLastSavedTime] = useState(null);
    const [hasUnsavedChanges, setHasUnsavedChanges] = useState(false);
    const [ipaPaletteVisible, setIpaPaletteVisible] = useState(false);
    const [ipaCategory, setIpaCategory] = useState('Vowels');
    const focusedInputRef = useRef(null);

    // First load state initialization flag to prevent premature saves
    const isInitialized = useRef(false);

    const [activeTab, setActiveTab] = useState('glosses');
    const [showState, setShowState] = useState(false);

    useEffect(() => {
        const saved = localStorage.getItem('lexsurv_state');
        if (saved) {
            setSavedSessionStatus('found');
        } else {
            setSavedSessionStatus('none');
            isInitialized.current = true;
        }

        const handleFocusIn = (e) => {
            if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
                focusedInputRef.current = e.target;
            }
        };
        document.addEventListener('focusin', handleFocusIn);
        return () => document.removeEventListener('focusin', handleFocusIn);
    }, []);

    // Auto-save debounced
    useEffect(() => {
        if (!isInitialized.current) return;

        setHasUnsavedChanges(true);
        const timer = setTimeout(() => {
            const stateToSave = {
                glossDictionaries,
                surveys,
                comparisons,
                timestamp: new Date().toISOString()
            };
            localStorage.setItem('lexsurv_state', JSON.stringify(stateToSave));
            setLastSavedTime(new Date());
            setHasUnsavedChanges(false);
        }, 500);

        return () => clearTimeout(timer);
    }, [glossDictionaries, surveys, comparisons]);

    const restoreSession = () => {
        try {
            const saved = localStorage.getItem('lexsurv_state');
            if (saved) {
                const data = JSON.parse(saved);
                if (data.glossDictionaries) setGlossDictionaries(data.glossDictionaries);
                if (data.surveys) setSurveys(data.surveys);
                if (data.comparisons) setComparisons(data.comparisons);
                if (data.timestamp) setLastSavedTime(new Date(data.timestamp));
            }
        } catch (e) {
            console.error("Failed to restore session", e);
        }
        setSavedSessionStatus('none');
        isInitialized.current = true;
    };

    const discardSession = () => {
        setSavedSessionStatus('none');
        isInitialized.current = true;
    };

    const handleExportProject = () => {
        const stateToSave = {
            glossDictionaries,
            surveys,
            comparisons,
            timestamp: new Date().toISOString(),
            version: '1.0'
        };
        const blob = new Blob([JSON.stringify(stateToSave, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `lexsurv_project_${new Date().toISOString().slice(0, 10)}.json`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
    };

    const handleImportProject = (e) => {
        const file = e.target.files[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = (evt) => {
            try {
                const data = JSON.parse(evt.target.result);
                if (data.glossDictionaries) setGlossDictionaries(data.glossDictionaries);
                if (data.surveys) setSurveys(data.surveys);
                if (data.comparisons) setComparisons(data.comparisons);

                isInitialized.current = true;
                setSavedSessionStatus('none');
                setActiveTab('glosses');
            } catch (err) {
                alert("Invalid project file");
            }
        };
        reader.readAsText(file);
        e.target.value = null;
    };

    const insertIpa = (char) => {
        const el = focusedInputRef.current;
        if (!el) return;
        const start = el.selectionStart;
        const end = el.selectionEnd;
        const val = el.value;
        const newVal = val.substring(0, start) + char + val.substring(end);

        // React inputs need native value setter to trigger onChange properly
        const nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, "value").set;
        nativeInputValueSetter.call(el, newVal);
        const ev = new Event('input', { bubbles: true });
        el.dispatchEvent(ev);

        // Restore cursor
        setTimeout(() => {
            el.focus();
            el.setSelectionRange(start + char.length, start + char.length);
        }, 0);
    };

    // Dictionaries UI State
    const [activeDictionaryId, setActiveDictionaryId] = useState(null);
    const [newDictName, setNewDictName] = useState('');

    // Wordlists UI State
    const [activeSurveyId, setActiveSurveyId] = useState(null);
    const [activeVarietyId, setActiveVarietyId] = useState(null);
    const [magnifiedText, setMagnifiedText] = useState('');
    const [newSurveyName, setNewSurveyName] = useState('');
    const [newSurveyDictId, setNewSurveyDictId] = useState('');

    // Comparisons UI State
    const [activeComparisonId, setActiveComparisonId] = useState(null);
    const [activeGlossId, setActiveGlossId] = useState(null);
    const [newCompName, setNewCompName] = useState('');
    const [newCompSurveyId, setNewCompSurveyId] = useState('');
    const [newCompType, setNewCompType] = useState('similarity');

    // Analysis and Results UI State
    const [analysisViewType, setAnalysisViewType] = useState('percent'); // 'total' | 'tally' | 'percent'
    const [selectedAnalysisCompId, setSelectedAnalysisCompId] = useState('');
    const [selectedResultsCompId, setSelectedResultsCompId] = useState('');

    // Initializer Functions
    const addGlossDictionary = (name) => {
        const newDict = {
            id: crypto.randomUUID(),
            name: name || 'New Dictionary',
            glosses: [] // { id, primary, secondary, pos, fieldTip }
        };
        setGlossDictionaries([...glossDictionaries, newDict]);
        setActiveDictionaryId(newDict.id);
        setNewDictName('');
    };

    const activeDict = glossDictionaries.find(d => d.id === activeDictionaryId);

    const updateActiveDictionaryGlosses = (newGlosses) => {
        setGlossDictionaries(glossDictionaries.map(dict =>
            dict.id === activeDictionaryId ? { ...dict, glosses: newGlosses } : dict
        ));
    };

    const addGlossRow = () => {
        if (!activeDict) return;
        updateActiveDictionaryGlosses([...activeDict.glosses, {
            id: crypto.randomUUID(), primary: '', secondary: '', pos: '', fieldTip: ''
        }]);
    };

    const updateGloss = (glossId, field, value) => {
        if (!activeDict) return;
        updateActiveDictionaryGlosses(activeDict.glosses.map(g =>
            g.id === glossId ? { ...g, [field]: value } : g
        ));
    };

    const deleteGloss = (glossId) => {
        if (!activeDict) return;
        updateActiveDictionaryGlosses(activeDict.glosses.filter(g => g.id !== glossId));
    };

    const loadPreset = (presetArray) => {
        if (!activeDict) return;
        const newGlosses = presetArray.map(item => ({
            id: crypto.randomUUID(),
            primary: item,
            secondary: '',
            pos: '',
            fieldTip: ''
        }));
        // Append or replace? Let's just append to be safe
        updateActiveDictionaryGlosses([...activeDict.glosses, ...newGlosses]);
    };

    const handleFileUpload = (e) => {
        const file = e.target.files[0];
        if (!file || !activeDict) return;

        const reader = new FileReader();
        reader.onload = (event) => {
            const text = event.target.result;
            const rows = text.split('\n').map(row => row.trim()).filter(row => row);
            if (rows.length <= 1) return; // Need at least header + 1 row

            // Assuming first row is header, map remaining rows
            const newGlosses = rows.slice(1).map(row => {
                const cols = row.split(',').map(c => c.replace(/^"|"$/g, '').trim());
                return {
                    id: crypto.randomUUID(),
                    primary: cols[0] || '',
                    secondary: cols[1] || '',
                    pos: cols[2] || '',
                    fieldTip: cols[3] || ''
                };
            });
            updateActiveDictionaryGlosses([...activeDict.glosses, ...newGlosses]);
        };
        reader.readAsText(file);
        e.target.value = null; // reset
    };

    const addSurvey = (name, dictionaryId) => {
        const newSurvey = {
            id: crypto.randomUUID(),
            name: name || 'New Survey',
            dictionaryId: dictionaryId || null,
            metadata: { fullTitle: '', description: '', compiler: '', consultant: '', area: '', location: '' },
            varieties: [] // { id, name, abbreviation, isoCode, metadata: {}, transcriptions: { [glossId]: { transcription, pluralFrame, notes, synonyms: [] } } }
        };
        setSurveys([...surveys, newSurvey]);
        return newSurvey;
    };

    const createUISurvey = () => {
        if (!newSurveyName.trim() || !newSurveyDictId) return;
        const s = addSurvey(newSurveyName.trim(), newSurveyDictId);
        setActiveSurveyId(s.id);
        setActiveVarietyId(null);
        setNewSurveyName('');
        setNewSurveyDictId('');
    };

    const activeSurvey = surveys.find(s => s.id === activeSurveyId);
    const activeVariety = activeSurvey?.varieties.find(v => v.id === activeVarietyId);
    const surveyDict = glossDictionaries.find(d => d.id === activeSurvey?.dictionaryId);

    const updateSurveyMetadata = (field, value) => {
        if (!activeSurvey) return;
        setSurveys(surveys.map(s =>
            s.id === activeSurveyId ? { ...s, metadata: { ...s.metadata, [field]: value } } : s
        ));
    };

    const addVarietyUI = () => {
        if (!activeSurvey) return;
        const newVariety = {
            id: crypto.randomUUID(),
            name: 'New Variety',
            abbreviation: '',
            isoCode: '',
            metadata: { alternateName: '' },
            transcriptions: {}
        };
        const updatedSurvey = { ...activeSurvey, varieties: [...activeSurvey.varieties, newVariety] };
        setSurveys(surveys.map(s => s.id === activeSurveyId ? updatedSurvey : s));
        setActiveVarietyId(newVariety.id);
    };

    const updateVarietyMetadata = (field, value, isNested = false) => {
        if (!activeSurvey || !activeVariety) return;
        const updatedVariety = isNested
            ? { ...activeVariety, metadata: { ...activeVariety.metadata, [field]: value } }
            : { ...activeVariety, [field]: value };

        const updatedSurvey = {
            ...activeSurvey,
            varieties: activeSurvey.varieties.map(v => v.id === activeVarietyId ? updatedVariety : v)
        };
        setSurveys(surveys.map(s => s.id === activeSurveyId ? updatedSurvey : s));
    };

    const updateTranscription = (glossId, field, value) => {
        if (!activeSurvey || !activeVariety) return;
        const currentTranscription = activeVariety.transcriptions[glossId] || { transcription: '', pluralFrame: '', notes: '', synonyms: [] };
        let newT = { ...currentTranscription, [field]: value };

        if (field === 'transcription') {
            setMagnifiedText(value);
        }

        const updatedVariety = {
            ...activeVariety,
            transcriptions: {
                ...activeVariety.transcriptions,
                [glossId]: newT
            }
        };

        const updatedSurvey = {
            ...activeSurvey,
            varieties: activeSurvey.varieties.map(v => v.id === activeVarietyId ? updatedVariety : v)
        };
        setSurveys(surveys.map(s => s.id === activeSurveyId ? updatedSurvey : s));
    };

    const addComparison = (name, surveyId, type = 'similarity') => {
        const newComparison = {
            id: crypto.randomUUID(),
            name: name || 'New Comparison',
            surveyId: surveyId || null,
            type: type, // 'similarity' | 'cognacy' | 'identical'
            judgments: {} // { [glossId]: { [varietyId]: { groupingChar, aligned, excluded, notes } } }
        };
        setComparisons([...comparisons, newComparison]);
        return newComparison;
    };

    const createUIComparison = () => {
        if (!newCompName.trim() || !newCompSurveyId) return;
        const c = addComparison(newCompName.trim(), newCompSurveyId, newCompType);
        setActiveComparisonId(c.id);
        setActiveGlossId(null);
        setNewCompName('');
        setNewCompSurveyId('');
    };

    const activeComparison = comparisons.find(c => c.id === activeComparisonId);
    const compSurvey = surveys.find(s => s.id === activeComparison?.surveyId);
    const compDict = glossDictionaries.find(d => d.id === compSurvey?.dictionaryId);

    const updateJudgment = (glossId, varietyId, field, value) => {
        if (!activeComparison) return;

        if (field === 'groupingChar' || field === 'aligned') {
            setMagnifiedText(value);
        }

        setComparisons(prev => prev.map(c => {
            if (c.id !== activeComparisonId) return c;

            // Get current judgments for this gloss, or empty object
            const currentGlossJudgments = c.judgments[glossId] || {};
            // Get current judgments for this variety inside this gloss, or default empty state
            const currentVarietyJudgment = currentGlossJudgments[varietyId] || { groupingChar: '', aligned: '', excluded: false, notes: '' };

            return {
                ...c,
                judgments: {
                    ...c.judgments,
                    [glossId]: {
                        ...currentGlossJudgments,
                        [varietyId]: {
                            ...currentVarietyJudgment,
                            [field]: value
                        }
                    }
                }
            };
        }));
    };

    // Deriving varieties count
    const varietiesCount = surveys.reduce((acc, s) => acc + (s.varieties?.length || 0), 0);

    const tabs = [
        { id: 'glosses', label: 'Gloss Dictionary', icon: Book, enabled: true },
        { id: 'wordlists', label: 'Wordlists', icon: List, enabled: glossDictionaries.length > 0 || true }, // Keeping true initially so user can see but prompt says "disabled/greyed until prerequisites exist", I'll make it true based on strict conditions... wait!
        // The prompt explicitly states: "(disabled/greyed until prerequisites exist): ...". But there is no way for the user to add glosses right now. 
        // I will strictly adhere to the prompt but let's make sure it looks correct.
        { id: 'comparisons', label: 'Comparisons', icon: SplitSquareVertical, enabled: surveys.length > 0 },
        { id: 'analysis', label: 'Analysis', icon: LineChart, enabled: comparisons.length > 0 },
        { id: 'results', label: 'Results Matrix', icon: Table, enabled: comparisons.length > 0 },
    ];

    const handleTabClick = (tab) => {
        if (tab.enabled) setActiveTab(tab.id);
    };

    const handleExportWordlistCSV = (surveyId) => {
        const survey = surveys.find(s => s.id === surveyId);
        if (!survey) return;
        const dict = glossDictionaries.find(d => d.id === survey.dictionaryId);
        if (!dict) return;

        let csvContent = "data:text/csv;charset=utf-8,";

        // Header
        const headers = ['Gloss', ...survey.varieties.map(v => v.name)];
        csvContent += headers.map(h => `"${h}"`).join(",") + "\n";

        // Rows
        dict.glosses.forEach(g => {
            const row = [`"${g.primary}"`]; // Quote primary gloss to handle commas
            survey.varieties.forEach(v => {
                const tr = (v.transcriptions[g.id]?.transcription || '').replace(/"/g, '""');
                row.push(`"${tr}"`);
            });
            csvContent += row.join(",") + "\n";
        });

        const encodedUri = encodeURI(csvContent);
        const link = document.createElement("a");
        link.setAttribute("href", encodedUri);
        link.setAttribute("download", `wordlist_${survey.name.replace(/\s+/g, '_')}.csv`);
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    };

    const handleImportWordlistCSV = (e, surveyId) => {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (evt) => {
            try {
                const text = evt.target.result;
                const rows = text.split('\n').filter(r => r.trim()).map(r => r.split(',').map(c => c.trim().replace(/^"|"$/g, '').replace(/""/g, '"')));
                if (rows.length < 2) return;

                const headers = rows[0];
                if (headers[0]?.toLowerCase() !== 'gloss') {
                    alert("First column header must be 'Gloss'");
                    return;
                }

                setSurveys(prevSurveys => prevSurveys.map(survey => {
                    if (survey.id !== surveyId) return survey;

                    const activeDict = glossDictionaries.find(d => d.id === survey.dictionaryId);
                    if (!activeDict) return survey;

                    // Deep clone varieties to modify
                    let updatedVarieties = JSON.parse(JSON.stringify(survey.varieties));

                    // Check which varieties in header exist, create new if needed
                    const varietyIndexes = {}; // index in header -> variety.id
                    for (let i = 1; i < headers.length; i++) {
                        const vName = headers[i];
                        if (!vName) continue;

                        let existingV = updatedVarieties.find(v => v.name === vName);
                        if (!existingV) {
                            existingV = {
                                id: Date.now().toString() + '-' + Math.random().toString(36).substr(2, 9),
                                name: vName,
                                abbreviation: vName.substring(0, 3).toUpperCase(),
                                isoCode: '',
                                metadata: { alternateName: '' },
                                transcriptions: {}
                            };
                            updatedVarieties.push(existingV);
                        }
                        varietyIndexes[i] = existingV.id;
                    }

                    // Map transcriptions
                    for (let r = 1; r < rows.length; r++) {
                        const columns = rows[r];
                        if (columns.length < 2) continue;

                        const glossName = columns[0];
                        if (!glossName) continue;

                        const matchedGloss = activeDict.glosses.find(g => g.primary.toLowerCase() === glossName.toLowerCase());
                        if (matchedGloss) {
                            for (let c = 1; c < columns.length; c++) {
                                const varId = varietyIndexes[c];
                                if (!varId) continue;
                                const transcription = columns[c] || '';

                                const vIndex = updatedVarieties.findIndex(v => v.id === varId);
                                if (vIndex !== -1) {
                                    if (!updatedVarieties[vIndex].transcriptions[matchedGloss.id]) {
                                        updatedVarieties[vIndex].transcriptions[matchedGloss.id] = { transcription: '', pluralFrame: '', notes: '' };
                                    }
                                    if (transcription.trim()) {
                                        updatedVarieties[vIndex].transcriptions[matchedGloss.id].transcription = transcription;
                                    }
                                }
                            }
                        }
                    }

                    return { ...survey, varieties: updatedVarieties };
                }));

                setHasUnsavedChanges(true);

            } catch (err) {
                console.error("Error parsing Wordlist CSV:", err);
                alert("Failed to parse Wordlist CSV.");
            }
        };
        reader.readAsText(file);
        e.target.value = null; // reset
    };

    const renderGlossesTab = () => {
        return (
            <div className="flex bg-white h-full">
                {/* Left Sidebar: Dictionary Selection */}
                <div className="w-1/4 border-r border-slate-200 p-4 bg-slate-50 flex flex-col gap-4">
                    <h2 className="text-lg font-bold text-slate-800">Dictionaries</h2>

                    {/* Create New Dictionary */}
                    <div className="flex gap-2">
                        <input
                            type="text"
                            className="flex-1 border border-slate-300 rounded px-2 py-1 text-sm focus:outline-none focus:border-blue-500"
                            placeholder="New dictionary name..."
                            value={newDictName}
                            onChange={e => setNewDictName(e.target.value)}
                            onKeyDown={e => { if (e.key === 'Enter' && newDictName.trim()) addGlossDictionary(newDictName.trim()); }}
                        />
                        <button
                            onClick={() => { if (newDictName.trim()) addGlossDictionary(newDictName.trim()); }}
                            className="bg-blue-600 text-white p-1.5 rounded hover:bg-blue-700 transition-colors"
                            title="Create Dictionary"
                        >
                            <Plus className="w-4 h-4" />
                        </button>
                    </div>

                    {/* Dictionary List */}
                    <div className="flex-1 overflow-y-auto space-y-1">
                        {glossDictionaries.length === 0 && (
                            <p className="text-sm text-slate-500 italic mt-2">No dictionaries created.</p>
                        )}
                        {glossDictionaries.map(dict => (
                            <button
                                key={dict.id}
                                onClick={() => setActiveDictionaryId(dict.id)}
                                className={`w-full text-left px-3 py-2 rounded text-sm transition-colors ${activeDictionaryId === dict.id ? 'bg-blue-100 text-blue-800 font-medium' : 'text-slate-700 hover:bg-slate-200'
                                    }`}
                            >
                                {dict.name} <span className="text-xs text-slate-400 float-right">({dict.glosses.length})</span>
                            </button>
                        ))}
                    </div>
                </div>

                {/* Right Area: Active Dictionary Editor */}
                <div className="w-3/4 flex flex-col relative h-[calc(100vh-14rem)]">
                    {!activeDict ? (
                        <div className="m-auto text-slate-400 flex flex-col items-center">
                            <Book className="w-12 h-12 mb-2 opacity-50" />
                            <p>Select or create a dictionary to edit glosses.</p>
                        </div>
                    ) : (
                        <>
                            {/* Toolbar */}
                            <div className="p-4 border-b border-slate-200 flex justify-between items-center bg-white sticky top-0 z-10">
                                <div>
                                    <h2 className="text-xl font-bold text-slate-800">{activeDict.name}</h2>
                                    <p className="text-sm text-slate-500">{activeDict.glosses.length} individual glosses</p>
                                </div>

                                <div className="flex items-center gap-3">
                                    <select
                                        className="text-sm border border-slate-300 rounded px-2 py-1.5 bg-white text-slate-700 cursor-pointer hover:border-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500"
                                        onChange={(e) => {
                                            if (!e.target.value) return;
                                            if (window.confirm("Append this preset to the current dictionary?")) {
                                                if (e.target.value === 'swadesh100') loadPreset(SWADESH_100);
                                                if (e.target.value === 'swadesh207') loadPreset(SWADESH_207);
                                                if (e.target.value === 'leipzig') loadPreset(LEIPZIG_JAKARTA_100);
                                            }
                                            e.target.value = ''; // reset select
                                        }}
                                    >
                                        <option value="">Load Preset...</option>
                                        <option value="swadesh100">Swadesh 100</option>
                                        <option value="swadesh207">Swadesh 207</option>
                                        <option value="leipzig">Leipzig-Jakarta 100</option>
                                    </select>

                                    <div className="relative">
                                        <input
                                            type="file"
                                            accept=".csv"
                                            onChange={handleFileUpload}
                                            className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                                            title="Import CSV (primary, secondary, pos, fieldTip)"
                                        />
                                        <button className="flex items-center gap-1.5 text-sm border border-slate-300 rounded px-3 py-1.5 hover:bg-slate-50 text-slate-700 transition-colors">
                                            <Upload className="w-4 h-4" />
                                            Import CSV
                                        </button>
                                    </div>

                                    <button
                                        onClick={addGlossRow}
                                        className="flex items-center gap-1.5 text-sm bg-blue-600 text-white rounded px-3 py-1.5 hover:bg-blue-700 transition-colors font-medium shadow-sm"
                                    >
                                        <Plus className="w-4 h-4" />
                                        Add Gloss
                                    </button>
                                </div>
                            </div>

                            {/* Table */}
                            <div className="flex-1 overflow-y-auto w-full">
                                <table className="w-full text-left border-collapse text-sm">
                                    <thead className="bg-slate-50 sticky top-0 shadow-sm z-0">
                                        <tr className="border-b border-slate-200">
                                            <th className="py-2 px-4 font-semibold text-slate-700 w-12 text-center">#</th>
                                            <th className="py-2 px-4 font-semibold text-slate-700 w-1/4">Primary Gloss</th>
                                            <th className="py-2 px-4 font-semibold text-slate-700 w-1/4">Secondary Gloss</th>
                                            <th className="py-2 px-4 font-semibold text-slate-700 w-1/6">POS</th>
                                            <th className="py-2 px-4 font-semibold text-slate-700 w-1/4">Field Tip</th>
                                            <th className="py-2 px-4 font-semibold text-slate-700 w-12"></th>
                                        </tr>
                                    </thead>
                                    <tbody className="divide-y divide-slate-100">
                                        {activeDict.glosses.length === 0 && (
                                            <tr>
                                                <td colSpan={6} className="py-8 text-center text-slate-500">
                                                    No glosses added yet. Import a CSV, load a preset, or add one manually.
                                                </td>
                                            </tr>
                                        )}
                                        {activeDict.glosses.map((gloss, idx) => (
                                            <tr key={gloss.id} className="hover:bg-blue-50/50 transition-colors group">
                                                <td className="py-2 px-4 text-center text-slate-400 select-none">{idx + 1}</td>
                                                <td className="py-1 px-2">
                                                    <input
                                                        type="text"
                                                        value={gloss.primary}
                                                        onChange={(e) => updateGloss(gloss.id, 'primary', e.target.value)}
                                                        className="w-full px-2 py-1.5 border border-transparent hover:border-slate-300 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 rounded bg-transparent focus:bg-white transition-all outline-none"
                                                        placeholder="e.g., eye"
                                                        onKeyDown={(e) => {
                                                            // Enter confirms and acts like Add row if at end
                                                            if (e.key === 'Enter') {
                                                                e.preventDefault();
                                                                if (idx === activeDict.glosses.length - 1) {
                                                                    addGlossRow(); // Add new row
                                                                }
                                                                // Focus management normally moves smoothly on Tab natively. Let's keep it simple.
                                                            }
                                                        }}
                                                    />
                                                </td>
                                                <td className="py-1 px-2">
                                                    <input
                                                        type="text"
                                                        value={gloss.secondary}
                                                        onChange={(e) => updateGloss(gloss.id, 'secondary', e.target.value)}
                                                        className="w-full px-2 py-1.5 border border-transparent hover:border-slate-300 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 rounded bg-transparent focus:bg-white transition-all outline-none"
                                                        placeholder="e.g., organ"
                                                    />
                                                </td>
                                                <td className="py-1 px-2">
                                                    <input
                                                        type="text"
                                                        value={gloss.pos}
                                                        onChange={(e) => updateGloss(gloss.id, 'pos', e.target.value)}
                                                        className="w-full px-2 py-1.5 border border-transparent hover:border-slate-300 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 rounded bg-transparent focus:bg-white transition-all outline-none text-slate-600 font-mono text-xs"
                                                        placeholder="e.g., N"
                                                    />
                                                </td>
                                                <td className="py-1 px-2">
                                                    <input
                                                        type="text"
                                                        value={gloss.fieldTip}
                                                        onChange={(e) => updateGloss(gloss.id, 'fieldTip', e.target.value)}
                                                        className="w-full px-2 py-1.5 border border-transparent hover:border-slate-300 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 rounded bg-transparent focus:bg-white transition-all outline-none italic text-slate-600"
                                                        placeholder="e.g., human only"
                                                    />
                                                </td>
                                                <td className="py-1 px-4 text-right">
                                                    <button
                                                        onClick={() => deleteGloss(gloss.id)}
                                                        className="text-slate-300 hover:text-red-500 transition-colors opacity-0 group-hover:opacity-100 focus:opacity-100 p-1 rounded hover:bg-red-50"
                                                        title="Delete Gloss"
                                                        tabIndex={-1} // remove from standard tab order to keep data entry fast
                                                    >
                                                        <Trash2 className="w-4 h-4" />
                                                    </button>
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        </>
                    )}
                </div>
            </div>
        );
    };

    const renderWordlistsTab = () => {
        return (
            <div className="flex bg-white h-full overflow-hidden">
                {/* Left Pane */}
                <div className="w-1/4 max-w-xs border-r border-slate-200 bg-slate-50 flex flex-col">
                    <div className="p-4 border-b border-slate-200 bg-white">
                        <h2 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-3">Surveys</h2>
                        <select
                            className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:border-blue-500 focus:outline-none mb-2 bg-white"
                            value={activeSurveyId || ''}
                            onChange={(e) => {
                                setActiveSurveyId(e.target.value === 'new' ? null : e.target.value);
                                setActiveVarietyId(null);
                            }}
                        >
                            <option value="" disabled>Select a Survey...</option>
                            {surveys.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                            <option value="new">+ Create New Survey</option>
                        </select>

                        {!activeSurveyId && (
                            <div className="space-y-2 mt-2 p-3 bg-slate-50 rounded border border-slate-200">
                                <input
                                    type="text"
                                    placeholder="Survey Name"
                                    className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:outline-none focus:border-blue-500"
                                    value={newSurveyName}
                                    onChange={e => setNewSurveyName(e.target.value)}
                                />
                                <select
                                    className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:outline-none focus:border-blue-500 bg-white text-slate-700"
                                    value={newSurveyDictId}
                                    onChange={e => setNewSurveyDictId(e.target.value)}
                                >
                                    <option value="" disabled>Link to Dictionary...</option>
                                    {glossDictionaries.map(d => <option key={d.id} value={d.id}>{d.name}</option>)}
                                </select>
                                <button
                                    onClick={createUISurvey}
                                    disabled={!newSurveyName.trim() || !newSurveyDictId}
                                    className="w-full bg-blue-600 text-white text-sm py-1.5 rounded hover:bg-blue-700 disabled:bg-slate-300 disabled:cursor-not-allowed transition-colors"
                                >
                                    Create Survey
                                </button>
                            </div>
                        )}
                    </div>

                    {activeSurvey && (
                        <div className="flex-1 flex flex-col overflow-hidden">
                            <div className="p-4 flex items-center justify-between border-b border-slate-200 bg-white">
                                <h3 className="text-sm font-bold text-slate-800">VARIETIES</h3>
                                <button
                                    onClick={addVarietyUI}
                                    className="text-blue-600 hover:text-blue-800 text-sm font-medium flex items-center"
                                >
                                    <Plus className="w-4 h-4 mr-0.5" /> New
                                </button>
                            </div>
                            <div className="flex-1 overflow-y-auto p-2 space-y-1">
                                {activeSurvey.varieties.length === 0 && (
                                    <p className="text-xs text-slate-500 italic px-2">No varieties in this survey yet.</p>
                                )}
                                {activeSurvey.varieties.map(v => (
                                    <button
                                        key={v.id}
                                        onClick={() => setActiveVarietyId(v.id)}
                                        className={`w-full text-left px-3 py-2 rounded text-sm transition-colors ${activeVarietyId === v.id ? 'bg-blue-100 text-blue-800 font-medium' : 'text-slate-700 hover:bg-slate-200'}`}
                                    >
                                        {v.name}
                                    </button>
                                ))}
                            </div>
                        </div>
                    )}
                </div>

                {/* Center Pane: Metadata */}
                <div className="w-1/4 max-w-md border-r border-slate-200 overflow-y-auto bg-white p-6">
                    {activeSurvey ? (
                        <>
                            <h2 className="text-lg font-bold text-slate-800 border-b border-slate-100 pb-2">Survey Metadata</h2>
                            <div className="flex justify-between items-center bg-slate-50 px-3 py-2 border-b border-slate-200 mb-4 rounded text-xs gap-2 shrink-0">
                                <span className="font-semibold text-slate-600">Data Transfer (CSV)</span>
                                <div className="flex gap-2">
                                    <label className="cursor-pointer flex items-center gap-1 border border-slate-300 rounded px-2 py-1 bg-white hover:bg-slate-50 transition-colors shadow-sm text-slate-700">
                                        <Upload className="w-3 h-3" /> Import
                                        <input type="file" accept=".csv" className="hidden" onChange={(e) => handleImportWordlistCSV(e, activeSurvey.id)} />
                                    </label>
                                    <button onClick={() => handleExportWordlistCSV(activeSurvey.id)} className="flex items-center gap-1 border border-slate-300 rounded px-2 py-1 bg-white hover:bg-slate-50 transition-colors shadow-sm text-slate-700">
                                        <Download className="w-3 h-3" /> Export
                                    </button>
                                </div>
                            </div>
                            <div className="space-y-3 mb-8">
                                <div><label className="block text-xs font-semibold text-slate-500 mb-1">Full Title</label><input type="text" value={activeSurvey.metadata.fullTitle || ''} onChange={e => updateSurveyMetadata('fullTitle', e.target.value)} className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:border-blue-500 focus:outline-none" /></div>
                                <div><label className="block text-xs font-semibold text-slate-500 mb-1">Description</label><textarea value={activeSurvey.metadata.description || ''} onChange={e => updateSurveyMetadata('description', e.target.value)} rows={3} className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:border-blue-500 focus:outline-none resize-none" /></div>
                                <div><label className="block text-xs font-semibold text-slate-500 mb-1">Compiler</label><input type="text" value={activeSurvey.metadata.compiler || ''} onChange={e => updateSurveyMetadata('compiler', e.target.value)} className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:border-blue-500 focus:outline-none" /></div>
                                <div><label className="block text-xs font-semibold text-slate-500 mb-1">Consultant</label><input type="text" value={activeSurvey.metadata.consultant || ''} onChange={e => updateSurveyMetadata('consultant', e.target.value)} className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:border-blue-500 focus:outline-none" /></div>
                                <div><label className="block text-xs font-semibold text-slate-500 mb-1">Area</label><input type="text" value={activeSurvey.metadata.area || ''} onChange={e => updateSurveyMetadata('area', e.target.value)} className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:border-blue-500 focus:outline-none" /></div>
                                <div><label className="block text-xs font-semibold text-slate-500 mb-1">Location</label><input type="text" value={activeSurvey.metadata.location || ''} onChange={e => updateSurveyMetadata('location', e.target.value)} className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:border-blue-500 focus:outline-none" /></div>
                            </div>
                        </>
                    ) : (
                        <div className="text-center text-slate-400 mt-10"><p>Select a survey to edit metadata.</p></div>
                    )}

                    {activeVariety && (
                        <>
                            <h2 className="text-lg font-bold text-slate-800 mb-4 border-b border-slate-100 pb-2">Variety Metadata</h2>
                            <div className="space-y-3">
                                <div><label className="block text-xs font-semibold text-slate-500 mb-1">Long Name</label><input type="text" value={activeVariety.name || ''} onChange={e => updateVarietyMetadata('name', e.target.value)} className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:border-blue-500 focus:outline-none font-medium" /></div>
                                <div><label className="block text-xs font-semibold text-slate-500 mb-1">Abbreviation</label><input type="text" value={activeVariety.abbreviation || ''} onChange={e => updateVarietyMetadata('abbreviation', e.target.value)} className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:border-blue-500 focus:outline-none" /></div>
                                <div><label className="block text-xs font-semibold text-slate-500 mb-1">ISO 639-3 Code</label><input type="text" value={activeVariety.isoCode || ''} onChange={e => updateVarietyMetadata('isoCode', e.target.value)} className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:border-blue-500 focus:outline-none font-mono" /></div>
                                <div><label className="block text-xs font-semibold text-slate-500 mb-1">Alternate Name</label><input type="text" value={activeVariety.metadata?.alternateName || ''} onChange={e => updateVarietyMetadata('alternateName', e.target.value, true)} className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:border-blue-500 focus:outline-none" /></div>
                            </div>
                        </>
                    )}
                </div>

                {/* Right Pane: Transcriptions Grid */}
                <div className="flex-1 flex flex-col bg-slate-50 relative">
                    {!activeVariety || !surveyDict ? (
                        <div className="m-auto text-slate-400 flex flex-col items-center p-8 text-center max-w-sm">
                            <List className="w-12 h-12 mb-4 opacity-30 text-slate-500" />
                            <p className="text-slate-500 font-medium">No active transcription context</p>
                            <p className="text-sm text-slate-400 mt-2">Please select a survey and variety on the left to begin entering data against the linked dictionary.</p>
                        </div>
                    ) : (() => {
                        const totalGlosses = surveyDict.glosses?.length || 0;
                        const enteredGlosses = surveyDict.glosses?.filter(g => {
                            const t = activeVariety.transcriptions[g.id]?.transcription;
                            return t && t.trim() !== '';
                        }).length || 0;
                        const pctComplete = totalGlosses > 0 ? Math.round((enteredGlosses / totalGlosses) * 100) : 0;

                        return (
                            <>
                                {/* Header */}
                                <div className="p-4 border-b border-slate-200 bg-white flex justify-between items-center shadow-sm z-10">
                                    <div>
                                        <h2 className="text-xl font-bold text-slate-800">{activeVariety.name} Transcriptions</h2>
                                        <p className="text-sm text-slate-500">{surveyDict.name} ({totalGlosses} glosses)</p>
                                    </div>
                                    <div className="flex flex-col items-end">
                                        <span className="text-sm font-medium text-slate-700">{enteredGlosses} / {totalGlosses} entered</span>
                                        <div className="w-32 bg-slate-200 rounded-full h-2 mt-1 relative overflow-hidden">
                                            <div className="bg-green-500 h-2 absolute left-0 top-0 transition-all duration-300" style={{ width: `${pctComplete}%` }}></div>
                                        </div>
                                    </div>
                                </div>

                                {/* Magnifier */}
                                <div className="px-6 py-4 bg-slate-800 text-white min-h-[5rem] flex items-center justify-center shadow-inner z-10">
                                    <span className={`font-mono text-3xl tracking-wide ${!magnifiedText ? 'opacity-30 italic text-xl' : ''}`}>
                                        {magnifiedText || 'Select a cell to magnify'}
                                    </span>
                                </div>

                                {/* Grid */}
                                <div className="flex-1 overflow-auto bg-white">
                                    <table className="w-full text-left border-collapse text-sm">
                                        <thead className="bg-slate-50 sticky top-0 shadow-sm z-0">
                                            <tr className="border-b border-slate-200">
                                                <th className="py-2 px-4 font-semibold text-slate-700 w-12 text-center">#</th>
                                                <th className="py-2 px-4 font-semibold text-slate-700 w-1/4">Gloss</th>
                                                <th className="py-2 px-4 font-semibold text-slate-700 w-1/3">Transcription</th>
                                                <th className="py-2 px-4 font-semibold text-slate-700 w-1/5">Plural / Frame</th>
                                                <th className="py-2 px-4 font-semibold text-slate-700">Notes</th>
                                            </tr>
                                        </thead>
                                        <tbody className="divide-y divide-slate-100">
                                            {totalGlosses === 0 && (
                                                <tr>
                                                    <td colSpan={5} className="py-8 text-center text-slate-500">
                                                        The linked dictionary "{surveyDict.name}" has no glosses.
                                                    </td>
                                                </tr>
                                            )}
                                            {surveyDict.glosses?.map((gloss, idx) => {
                                                const transcData = activeVariety.transcriptions[gloss.id] || { transcription: '', pluralFrame: '', notes: '' };
                                                const hasTranscription = transcData.transcription?.trim() !== '';

                                                return (
                                                    <tr key={gloss.id} className={`transition-colors text-slate-800 ${!hasTranscription ? 'bg-amber-50/40 hover:bg-amber-100/50' : 'hover:bg-blue-50/50'}`}>
                                                        <td className="py-2 px-4 text-center text-slate-400 select-none">{idx + 1}</td>
                                                        <td className="py-2 px-4">
                                                            <div className="font-medium text-slate-800">{gloss.primary}</div>
                                                            {gloss.secondary && <div className="text-xs text-slate-500">{gloss.secondary}</div>}
                                                        </td>
                                                        <td className="py-1 px-2 border-l border-r border-slate-100">
                                                            <input
                                                                type="text"
                                                                className="w-full px-2 py-1.5 focus:bg-white rounded border border-transparent hover:border-slate-300 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 bg-transparent outline-none font-medium transcription-input transition-colors"
                                                                value={transcData.transcription}
                                                                onChange={(e) => updateTranscription(gloss.id, 'transcription', e.target.value)}
                                                                onFocus={(e) => { e.target.select(); setMagnifiedText(e.target.value); }}
                                                                onClick={(e) => e.target.select()}
                                                                placeholder="Transcription (comma for synonyms)"
                                                                onKeyDown={(e) => {
                                                                    if (e.key === 'Enter') {
                                                                        e.preventDefault();
                                                                        const inputs = Array.from(document.querySelectorAll('.transcription-input'));
                                                                        const currentIndex = inputs.indexOf(e.target);
                                                                        if (currentIndex !== -1 && currentIndex + 1 < inputs.length) {
                                                                            inputs[currentIndex + 1].focus();
                                                                        }
                                                                    }
                                                                }}
                                                            />
                                                        </td>
                                                        <td className="py-1 px-2">
                                                            <input
                                                                type="text"
                                                                className="w-full px-2 py-1.5 focus:bg-white rounded border border-transparent hover:border-slate-300 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 bg-transparent outline-none text-slate-600 transition-colors"
                                                                value={transcData.pluralFrame}
                                                                onChange={(e) => updateTranscription(gloss.id, 'pluralFrame', e.target.value)}
                                                                onFocus={(e) => { e.target.select(); setMagnifiedText(e.target.value); }}
                                                                onClick={(e) => e.target.select()}
                                                                placeholder="Frame"
                                                            />
                                                        </td>
                                                        <td className="py-1 px-2">
                                                            <input
                                                                type="text"
                                                                className="w-full px-2 py-1.5 focus:bg-white rounded border border-transparent hover:border-slate-300 focus:border-blue-500 focus:ring-1 focus:ring-blue-500 bg-transparent outline-none text-slate-500 italic text-xs transition-colors"
                                                                value={transcData.notes}
                                                                onChange={(e) => updateTranscription(gloss.id, 'notes', e.target.value)}
                                                                onFocus={(e) => { e.target.select(); setMagnifiedText(e.target.value); }}
                                                                onClick={(e) => e.target.select()}
                                                                placeholder="Notes..."
                                                            />
                                                        </td>
                                                    </tr>
                                                );
                                            })}
                                        </tbody>
                                    </table>
                                </div>
                            </>
                        );
                    })()}
                </div>
            </div>
        );
    };

    const renderComparisonsTab = () => {
        return (
            <div className="flex bg-white h-full overflow-hidden">
                {/* Left Pane: Selection & Glosses */}
                <div className="w-1/4 max-w-sm border-r border-slate-200 bg-slate-50 flex flex-col">
                    <div className="p-4 border-b border-slate-200 bg-white">
                        <h2 className="text-sm font-bold text-slate-800 uppercase tracking-wider mb-3">Comparisons</h2>
                        <select
                            className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:border-blue-500 focus:outline-none mb-2 bg-white"
                            value={activeComparisonId || ''}
                            onChange={(e) => {
                                setActiveComparisonId(e.target.value === 'new' ? null : e.target.value);
                                setActiveGlossId(null);
                            }}
                        >
                            <option value="" disabled>Select a Comparison...</option>
                            {comparisons.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
                            <option value="new">+ Create New Comparison</option>
                        </select>

                        {!activeComparisonId && (
                            <div className="space-y-2 mt-2 p-3 bg-slate-50 rounded border border-slate-200">
                                <input
                                    type="text"
                                    placeholder="Comparison Name"
                                    className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:outline-none focus:border-blue-500"
                                    value={newCompName}
                                    onChange={e => setNewCompName(e.target.value)}
                                />
                                <select
                                    className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:outline-none focus:border-blue-500 bg-white text-slate-700"
                                    value={newCompSurveyId}
                                    onChange={e => setNewCompSurveyId(e.target.value)}
                                >
                                    <option value="" disabled>Based on Survey...</option>
                                    {surveys.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                                </select>
                                <select
                                    className="w-full text-sm border border-slate-300 rounded px-2 py-1.5 focus:outline-none focus:border-blue-500 bg-white text-slate-700"
                                    value={newCompType}
                                    onChange={e => setNewCompType(e.target.value)}
                                >
                                    <option value="similarity">Similarity (Lexicostatistics)</option>
                                    <option value="cognacy">Cognacy (Historical)</option>
                                    <option value="identical">Exact Match</option>
                                </select>
                                <button
                                    onClick={createUIComparison}
                                    disabled={!newCompName.trim() || !newCompSurveyId}
                                    className="w-full bg-blue-600 text-white text-sm py-1.5 rounded hover:bg-blue-700 disabled:bg-slate-300 disabled:cursor-not-allowed transition-colors"
                                >
                                    Create Comparison
                                </button>
                            </div>
                        )}
                    </div>

                    {activeComparison && compDict && (
                        <div className="flex-1 flex flex-col overflow-hidden">
                            <div className="p-3 bg-slate-100 border-b border-slate-200 text-xs text-slate-600 flex justify-between items-center">
                                <span className="font-semibold">{compDict.glosses.length} Glosses</span>
                                <span>Type: <span className="capitalize text-slate-800 font-medium">{activeComparison.type}</span></span>
                            </div>
                            <div className="flex-1 overflow-y-auto p-2 space-y-0.5">
                                {compDict.glosses?.map(gloss => {
                                    // Determine grouping status
                                    const requiredVarieties = compSurvey.varieties.length;
                                    const glossJudgments = activeComparison.judgments[gloss.id] || {};
                                    let groupedCount = 0;
                                    let excludedCount = 0;

                                    compSurvey.varieties.forEach(v => {
                                        const j = glossJudgments[v.id];
                                        if (j?.excluded) excludedCount++;
                                        else if (j?.groupingChar?.trim()) groupedCount++;
                                    });

                                    const activeTarget = requiredVarieties - excludedCount;
                                    let statusIcon = "○"; // ungrouped
                                    let statusColor = "text-slate-300";

                                    if (activeTarget > 0 && groupedCount === activeTarget) {
                                        statusIcon = "✓"; // fully grouped
                                        statusColor = "text-green-500";
                                    } else if (groupedCount > 0) {
                                        statusIcon = "◑"; // partially
                                        statusColor = "text-amber-400";
                                    }

                                    return (
                                        <button
                                            key={gloss.id}
                                            onClick={() => {
                                                setActiveGlossId(gloss.id);
                                                setMagnifiedText('');
                                            }}
                                            className={`w-full text-left px-3 py-1.5 rounded text-sm transition-colors flex items-center justify-between ${activeGlossId === gloss.id ? 'bg-blue-100 text-blue-800 font-medium' : 'text-slate-700 hover:bg-slate-200'}`}
                                        >
                                            <span className="truncate pr-2">{gloss.primary}</span>
                                            <span className={`text-base leading-none ${statusColor}`} title={statusIcon === '✓' ? 'Fully grouped' : statusIcon === '◑' ? 'Partially grouped' : 'Ungrouped'}>{statusIcon}</span>
                                        </button>
                                    );
                                })}
                            </div>
                        </div>
                    )}
                </div>

                {/* Right Pane: Judgment Grid */}
                <div className="flex-1 flex flex-col bg-slate-50 relative">
                    {!activeComparison || !compSurvey || !compDict ? (
                        <div className="m-auto text-slate-400 flex flex-col items-center p-8 text-center max-w-sm">
                            <SplitSquareVertical className="w-12 h-12 mb-4 opacity-30 text-slate-500" />
                            <p className="text-slate-500 font-medium">No active comparison context</p>
                            <p className="text-sm text-slate-400 mt-2">Create or select a comparison on the left to begin judging grouping classes.</p>
                        </div>
                    ) : !activeGlossId ? (
                        <div className="m-auto text-slate-400 flex flex-col items-center p-8 text-center max-w-sm">
                            <div className="w-12 h-12 mb-4 opacity-30 text-slate-500 text-4xl flex items-center justify-center">○</div>
                            <p className="text-slate-500 font-medium">Select a gloss</p>
                            <p className="text-sm text-slate-400 mt-2">Choose a gloss from the left sidebar to assign judgment groupings for its varieties.</p>
                        </div>
                    ) : (() => {
                        const activeGloss = compDict.glosses.find(g => g.id === activeGlossId);

                        // Calculate overall completion
                        const totalReq = compDict.glosses.length * compSurvey.varieties.length;
                        let totalDone = 0;
                        compDict.glosses.forEach(g => {
                            const jSet = activeComparison.judgments[g.id] || {};
                            compSurvey.varieties.forEach(v => {
                                if (jSet[v.id]?.excluded || jSet[v.id]?.groupingChar?.trim()) totalDone++;
                            });
                        });
                        const totalPct = totalReq > 0 ? Math.round((totalDone / totalReq) * 100) : 0;

                        // Gloss statistics
                        const activeJudgments = activeComparison.judgments[activeGlossId] || {};
                        let gDone = 0;
                        let gExcluded = 0;
                        compSurvey.varieties.forEach(v => {
                            if (activeJudgments[v.id]?.excluded) gExcluded++;
                            else if (activeJudgments[v.id]?.groupingChar?.trim()) gDone++;
                        });

                        return (
                            <>
                                {/* Header */}
                                <div className="p-4 border-b border-slate-200 bg-white flex justify-between items-center shadow-sm z-10">
                                    <div>
                                        <h2 className="text-2xl font-bold text-slate-800 flex items-center gap-3">
                                            {activeGloss.primary}
                                            {activeGloss.secondary && <span className="text-lg font-normal text-slate-500">({activeGloss.secondary})</span>}
                                        </h2>
                                        <div className="text-xs text-slate-500 mt-1 flex gap-4">
                                            <span><strong>Comparison:</strong> {activeComparison.name}</span>
                                            <span><strong>Survey:</strong> {compSurvey.name}</span>
                                        </div>
                                    </div>
                                    <div className="flex flex-col items-end">
                                        <span className="text-sm font-medium text-slate-700">Project: {totalPct}% Complete</span>
                                        <div className="w-32 bg-slate-200 rounded-full h-2 mt-1 relative overflow-hidden">
                                            <div className="bg-blue-500 h-2 absolute left-0 top-0 transition-all duration-300" style={{ width: `${totalPct}%` }}></div>
                                        </div>
                                        <span className="text-xs text-slate-400 mt-1">{gDone} grouped, {gExcluded} excluded</span>
                                    </div>
                                </div>

                                {/* Magnifier & Guidance */}
                                <div className="bg-slate-800 text-white min-h-[6rem] flex flex-col justify-center items-center shadow-inner z-10 relative">
                                    <div className="absolute top-2 left-4 text-xs text-slate-400 bg-slate-900/50 px-2 py-1 rounded">
                                        Grouping: (a) = set 1, (b) = set 2. Use spaces for multiple sets.
                                    </div>
                                    <div className="absolute top-2 right-4 text-xs text-slate-400 bg-slate-900/50 px-2 py-1 rounded text-right flex flex-col">
                                        <span><kbd className="bg-slate-700 px-1 rounded">Ctrl+Enter</kbd> Next Gloss</span>
                                        <span><kbd className="bg-slate-700 px-1 rounded">Ctrl+G</kbd> Next Ungrouped</span>
                                        <span><kbd className="bg-slate-700 px-1 rounded">Ctrl+E</kbd> Exclude All</span>
                                    </div>
                                    <span className={`font-mono text-4xl mt-3 tracking-wide ${!magnifiedText ? 'opacity-30 italic text-2xl' : ''}`}>
                                        {magnifiedText || 'Select transcription or grouping to magnify'}
                                    </span>
                                </div>

                                {/* Judgment Grid */}
                                <div
                                    className="flex-1 overflow-auto bg-white p-4"
                                    onKeyDown={(e) => {
                                        // Keyboard shortcuts wrapper
                                        if (e.ctrlKey && e.key === 'Enter') {
                                            e.preventDefault();
                                            const idx = compDict.glosses.findIndex(g => g.id === activeGlossId);
                                            if (idx < compDict.glosses.length - 1) setActiveGlossId(compDict.glosses[idx + 1].id);
                                        }
                                        else if (e.ctrlKey && e.key === 'g') {
                                            e.preventDefault();
                                            // Find next ungrouped
                                            const currentIndex = compDict.glosses.findIndex(g => g.id === activeGlossId);
                                            for (let i = currentIndex + 1; i < compDict.glosses.length; i++) {
                                                const gList = compDict.glosses[i];
                                                const jSet = activeComparison.judgments[gList.id] || {};
                                                let isDone = true;
                                                for (let v of compSurvey.varieties) {
                                                    if (!jSet[v.id]?.excluded && !jSet[v.id]?.groupingChar?.trim()) {
                                                        isDone = false; break;
                                                    }
                                                }
                                                if (!isDone) {
                                                    setActiveGlossId(gList.id);
                                                    break;
                                                }
                                            }
                                        }
                                        else if (e.ctrlKey && e.key === 'e') {
                                            e.preventDefault();
                                            compSurvey.varieties.forEach(v => updateJudgment(activeGlossId, v.id, 'excluded', true));
                                        }
                                    }}
                                >
                                    <table className="w-full text-left border-collapse text-sm border-slate-200 border">
                                        <thead className="bg-slate-100 sticky top-0 z-0">
                                            <tr>
                                                <th className="py-2 px-4 font-semibold text-slate-700 w-1/5 border-b border-r border-slate-200">Variety</th>
                                                <th className="py-2 px-4 font-semibold text-slate-700 w-1/4 border-b border-r border-slate-200">Transcription <span className="font-normal text-xs text-slate-400">(Read only)</span></th>
                                                <th className="py-2 px-4 font-semibold text-slate-700 w-[15%] border-b border-r border-slate-200">Aligned</th>
                                                <th className="py-2 px-4 font-semibold text-slate-700 w-24 border-b border-r border-slate-200 bg-blue-50">Grouping</th>
                                                <th className="py-2 px-4 font-semibold text-slate-700 border-b border-r border-slate-200">Notes</th>
                                                <th className="py-2 px-2 font-semibold text-slate-700 w-16 border-b border-slate-200 text-center text-xs">Exclude</th>
                                            </tr>
                                        </thead>
                                        <tbody className="divide-y divide-slate-200">
                                            {compSurvey.varieties.map((variety, rIdx) => {
                                                const transcData = variety.transcriptions[activeGlossId] || {};
                                                const transcText = transcData.transcription || '';
                                                const originalFrame = transcData.pluralFrame || '';

                                                const judgData = activeJudgments[variety.id] || { groupingChar: '', aligned: '', excluded: false, notes: '' };
                                                const isExcluded = judgData.excluded;
                                                const hasGrouping = judgData.groupingChar?.trim() !== '';

                                                return (
                                                    <tr key={variety.id} className={`transition-colors ${isExcluded ? 'bg-slate-100 opacity-60' : hasGrouping ? 'bg-green-50/30' : 'hover:bg-blue-50/30'}`}>
                                                        <td className="py-2 px-4 border-r border-slate-200 font-medium text-slate-800">
                                                            {variety.name}
                                                            {variety.abbreviation && <span className="text-xs text-slate-400 ml-2 border border-slate-200 rounded px-1">{variety.abbreviation}</span>}
                                                        </td>
                                                        <td
                                                            className="py-2 px-4 border-r border-slate-200 text-lg cursor-pointer hover:bg-slate-100 transition-colors"
                                                            onClick={() => setMagnifiedText(transcText)}
                                                        >
                                                            {transcText || <span className="text-xs italic text-slate-400">No data</span>}
                                                            {originalFrame && <div className="text-xs text-slate-500 mt-1 font-mono">{originalFrame}</div>}
                                                        </td>
                                                        <td className="py-1 px-2 border-r border-slate-200 font-mono text-lg">
                                                            <input
                                                                type="text"
                                                                className={`w-full px-2 py-2 focus:bg-white rounded border border-transparent focus:border-blue-500 focus:ring-1 focus:ring-blue-500 outline-none transition-colors ${isExcluded ? 'bg-transparent text-slate-400' : 'bg-slate-50'}`}
                                                                value={judgData.aligned}
                                                                onChange={(e) => updateJudgment(activeGlossId, variety.id, 'aligned', e.target.value)}
                                                                onFocus={(e) => { e.target.select(); setMagnifiedText(e.target.value || transcText); }}
                                                                disabled={isExcluded}
                                                                placeholder={transcText}
                                                            />
                                                        </td>
                                                        <td className="py-1 px-2 border-r border-slate-200 font-mono text-center">
                                                            <input
                                                                type="text"
                                                                className={`w-full px-2 py-2 text-center text-xl font-bold focus:bg-white rounded border border-transparent focus:border-blue-500 focus:ring-2 focus:ring-blue-500 outline-none transition-colors ${isExcluded ? 'bg-transparent text-slate-300 shadow-none' : 'bg-blue-50 text-blue-800 shadow-inner'}`}
                                                                value={judgData.groupingChar}
                                                                onChange={(e) => updateJudgment(activeGlossId, variety.id, 'groupingChar', e.target.value)}
                                                                onFocus={(e) => { e.target.select(); setMagnifiedText(e.target.value); }}
                                                                disabled={isExcluded}
                                                                onKeyDown={(e) => {
                                                                    if (e.key === 'ArrowDown') {
                                                                        e.preventDefault();
                                                                        const inputs = Array.from(document.querySelectorAll('.grouping-input'));
                                                                        const currentIndex = inputs.indexOf(e.target);
                                                                        if (currentIndex !== -1 && currentIndex + 1 < inputs.length) inputs[currentIndex + 1].focus();
                                                                    } else if (e.key === 'ArrowUp') {
                                                                        e.preventDefault();
                                                                        const inputs = Array.from(document.querySelectorAll('.grouping-input'));
                                                                        const currentIndex = inputs.indexOf(e.target);
                                                                        if (currentIndex > 0) inputs[currentIndex - 1].focus();
                                                                    }
                                                                }}
                                                                placeholder="a b"
                                                                data-idx={rIdx}
                                                            />
                                                        </td>
                                                        <td className="py-1 px-2 border-r border-slate-200">
                                                            <input
                                                                type="text"
                                                                className={`w-full px-2 py-2 focus:bg-white rounded border border-transparent focus:border-blue-500 focus:ring-1 focus:ring-blue-500 outline-none text-xs transition-colors ${isExcluded ? 'bg-transparent text-slate-400' : 'bg-slate-50'}`}
                                                                value={judgData.notes}
                                                                onChange={(e) => updateJudgment(activeGlossId, variety.id, 'notes', e.target.value)}
                                                                disabled={isExcluded}
                                                                placeholder="Judgment notes"
                                                            />
                                                        </td>
                                                        <td className="py-1 px-4 text-center">
                                                            <input
                                                                type="checkbox"
                                                                className="w-5 h-5 rounded text-blue-600 focus:ring-blue-500 cursor-pointer"
                                                                checked={isExcluded}
                                                                onChange={(e) => updateJudgment(activeGlossId, variety.id, 'excluded', e.target.checked)}
                                                            />
                                                        </td>
                                                    </tr>
                                                );
                                            })}
                                        </tbody>
                                    </table>
                                </div>
                            </>
                        );
                    })()}
                </div>
            </div>
        );
    };

    const renderAnalysisTab = () => {
        const activeComp = comparisons.find(c => c.id === selectedAnalysisCompId) || comparisons[0];
        if (!activeComp && comparisons.length > 0) setSelectedAnalysisCompId(comparisons[0].id);

        if (!activeComp) {
            return (
                <div className="m-auto text-slate-400 flex flex-col items-center p-8 text-center max-w-sm mt-20">
                    <LineChart className="w-12 h-12 mb-4 opacity-30 text-slate-500" />
                    <p className="text-slate-500 font-medium">No comparisons available</p>
                    <p className="text-sm text-slate-400 mt-2">Create a comparison and judge varieties to view analysis.</p>
                </div>
            );
        }

        const survey = surveys.find(s => s.id === activeComp.surveyId);
        const dict = glossDictionaries.find(d => d.id === survey?.dictionaryId);

        if (!survey || !dict || survey.varieties.length < 2) {
            return (
                <div className="m-auto text-slate-400 flex flex-col items-center p-8 text-center max-w-md mt-20">
                    <LineChart className="w-12 h-12 mb-4 opacity-30 text-slate-500" />
                    <p className="text-slate-500 font-medium">Insufficient Data</p>
                    <p className="text-sm text-slate-400 mt-2">The selected comparison requires a linked survey with at least two varieties to generate a matrix.</p>
                </div>
            );
        }

        // Calculate lexicostatistical matrix
        const varieties = survey.varieties;
        const matrix = []; // 2D array: matrix[r][c] = { total, tally, percent }

        for (let i = 0; i < varieties.length; i++) {
            matrix[i] = [];
            for (let j = 0; j <= i; j++) {
                const varA = varieties[i];
                const varB = varieties[j];

                if (i === j) {
                    matrix[i][j] = { total: dict.glosses.length, tally: dict.glosses.length, percent: 100 };
                    continue;
                }

                let total = 0;
                let tally = 0;

                dict.glosses.forEach(gloss => {
                    const jA = activeComp.judgments[gloss.id]?.[varA.id];
                    const jB = activeComp.judgments[gloss.id]?.[varB.id];

                    const excludedA = jA?.excluded;
                    const excludedB = jB?.excluded;

                    const hasTranscriptionA = varA.transcriptions[gloss.id]?.transcription?.trim() !== '';
                    const hasTranscriptionB = varB.transcriptions[gloss.id]?.transcription?.trim() !== '';

                    // For "total" denominator: both must NOT be excluded, and both must have SOME transcription typed
                    if (!excludedA && !excludedB && (hasTranscriptionA || jA?.groupingChar) && (hasTranscriptionB || jB?.groupingChar)) {
                        total++;

                        // For "tally" numerator: do they share a group?
                        const groupsA = (jA?.groupingChar || '').split(' ').filter(x => x);
                        const groupsB = (jB?.groupingChar || '').split(' ').filter(x => x);

                        // Intersection check
                        if (groupsA.length > 0 && groupsB.length > 0 && groupsA.some(g => groupsB.includes(g))) {
                            tally++;
                        }
                    }
                });

                const percent = total > 0 ? Math.round((tally / total) * 100) : 0;
                matrix[i][j] = { total, tally, percent };
            }
        }

        // Color coding logic
        const getColorClass = (pct) => {
            if (pct >= 75) return 'bg-green-100 text-green-800';
            if (pct >= 50) return 'bg-lime-100 text-lime-800';
            if (pct >= 25) return 'bg-yellow-100 text-yellow-800';
            return 'bg-red-100 text-red-800';
        };

        return (
            <div className="flex flex-col h-full overflow-hidden bg-slate-50">
                {/* Header Controls */}
                <div className="bg-white border-b border-slate-200 p-4 shadow-sm flex justify-between items-center z-10 shrink-0">
                    <div className="flex items-center gap-4">
                        <select
                            className="text-sm border border-slate-300 rounded px-3 py-2 bg-white font-medium text-slate-800 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                            value={activeComp.id}
                            onChange={e => setSelectedAnalysisCompId(e.target.value)}
                        >
                            {comparisons.map(c => <option key={c.id} value={c.id}>{c.name} ({c.type})</option>)}
                        </select>
                        <span className="text-sm text-slate-500">{survey.name}</span>
                    </div>

                    <div className="flex bg-slate-100 p-1 rounded-lg border border-slate-200">
                        {['total', 'tally', 'percent'].map(mode => (
                            <button
                                key={mode}
                                onClick={() => setAnalysisViewType(mode)}
                                className={`px-4 py-1.5 text-sm font-medium rounded-md capitalize transition-colors ${analysisViewType === mode ? 'bg-white text-blue-700 shadow-sm' : 'text-slate-600 hover:text-slate-900'}`}
                            >
                                {mode}
                            </button>
                        ))}
                    </div>
                </div>

                {/* Matrix Display */}
                <div className="flex-1 overflow-auto p-8">
                    <div className="inline-block bg-white p-6 rounded-xl shadow-sm border border-slate-200">
                        <table className="border-collapse">
                            <thead>
                                <tr>
                                    <th className="p-2 border-slate-200 border-b border-r text-right bg-slate-50 sticky left-0 z-10 min-w-[12rem]"></th>
                                    {varieties.map((v, i) => (
                                        <th key={v.id} className="p-2 w-16 text-xs text-center border-b border-slate-200 font-bold text-slate-600 truncate" title={v.name}>
                                            {v.abbreviation || v.name.substring(0, 3).toUpperCase()}
                                        </th>
                                    ))}
                                </tr>
                            </thead>
                            <tbody>
                                {varieties.map((vRow, rIdx) => (
                                    <tr key={vRow.id}>
                                        <th className="p-2 px-4 text-sm font-semibold text-slate-700 border-r border-slate-200 text-right bg-slate-50 sticky left-0 shadow-sm truncate max-w-[12rem]" title={vRow.name}>
                                            {vRow.name}
                                        </th>
                                        {varieties.map((vCol, cIdx) => {
                                            if (cIdx > rIdx) return <td key={vCol.id} className="p-2 bg-slate-50/50 border border-slate-100"></td>;

                                            const cell = matrix[rIdx][cIdx];
                                            let displayVal = cell.percent + '%';
                                            if (analysisViewType === 'total') displayVal = cell.total;
                                            if (analysisViewType === 'tally') displayVal = cell.tally;

                                            return (
                                                <td
                                                    key={vCol.id}
                                                    className={`p-2 border border-white text-center text-sm font-medium transition-colors hover:opacity-80 cursor-default ${cIdx === rIdx ? 'bg-slate-200 text-slate-600' : getColorClass(cell.percent)}`}
                                                    title={`${vRow.name} ↔ ${vCol.name}\nTally: ${cell.tally}\nTotal: ${cell.total}\nPercent: ${cell.percent}%`}
                                                >
                                                    {displayVal}
                                                </td>
                                            );
                                        })}
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>

                    {/* Legend */}
                    {analysisViewType === 'percent' && (
                        <div className="mt-8 flex items-center gap-4 text-sm text-slate-600 justify-center">
                            <span className="font-semibold mr-2">Legend:</span>
                            <div className="flex items-center gap-1.5"><div className="w-4 h-4 rounded bg-green-100 border border-green-200"></div> &gt; 75%</div>
                            <div className="flex items-center gap-1.5"><div className="w-4 h-4 rounded bg-lime-100 border border-lime-200"></div> 50-75%</div>
                            <div className="flex items-center gap-1.5"><div className="w-4 h-4 rounded bg-yellow-100 border border-yellow-200"></div> 25-50%</div>
                            <div className="flex items-center gap-1.5"><div className="w-4 h-4 rounded bg-red-100 border border-red-200"></div> &lt; 25%</div>
                        </div>
                    )}
                </div>
            </div>
        );
    };

    const renderResultsTab = () => {
        const activeComp = comparisons.find(c => c.id === selectedResultsCompId) || comparisons[0];
        if (!activeComp && comparisons.length > 0) setSelectedResultsCompId(comparisons[0].id);

        if (!activeComp) {
            return (
                <div className="m-auto text-slate-400 flex flex-col items-center p-8 text-center max-w-sm mt-20">
                    <Table className="w-12 h-12 mb-4 opacity-30 text-slate-500" />
                    <p className="text-slate-500 font-medium">No comparisons available</p>
                    <p className="text-sm text-slate-400 mt-2">Generate a lexicostatistical comparison first.</p>
                </div>
            );
        }

        const survey = surveys.find(s => s.id === activeComp.surveyId);
        const dict = glossDictionaries.find(d => d.id === survey?.dictionaryId);

        if (!survey || !dict || survey.varieties.length < 2) return null;

        const varieties = survey.varieties;
        const matrix = [];

        // Generate matrix logic again for exports
        for (let i = 0; i < varieties.length; i++) {
            matrix[i] = [];
            for (let j = 0; j <= i; j++) {
                if (i === j) {
                    matrix[i][j] = 100;
                    continue;
                }

                let total = 0;
                let tally = 0;

                dict.glosses.forEach(gloss => {
                    const jA = activeComp.judgments[gloss.id]?.[varieties[i].id];
                    const jB = activeComp.judgments[gloss.id]?.[varieties[j].id];

                    const excludedA = jA?.excluded;
                    const excludedB = jB?.excluded;

                    const hasTranscriptionA = varieties[i].transcriptions[gloss.id]?.transcription?.trim() !== '';
                    const hasTranscriptionB = varieties[j].transcriptions[gloss.id]?.transcription?.trim() !== '';

                    if (!excludedA && !excludedB && (hasTranscriptionA || jA?.groupingChar) && (hasTranscriptionB || jB?.groupingChar)) {
                        total++;
                        const groupsA = (jA?.groupingChar || '').split(' ').filter(x => x);
                        const groupsB = (jB?.groupingChar || '').split(' ').filter(x => x);
                        if (groupsA.length > 0 && groupsB.length > 0 && groupsA.some(g => groupsB.includes(g))) { tally++; }
                    }
                });

                matrix[i][j] = total > 0 ? Math.round((tally / total) * 100) : 0;
            }
        }

        const handleDownloadCSV = () => {
            let csvContent = "data:text/csv;charset=utf-8,";

            // Header row with varieties offset
            const headers = ['Variety'].concat(varieties.map(v => v.name));
            csvContent += headers.join(",") + "\n";

            // Matrix rows
            varieties.forEach((vRow, rIdx) => {
                let row = [vRow.name];
                varieties.forEach((vCol, cIdx) => {
                    if (cIdx > rIdx) row.push(""); // Empty upper triangle
                    else row.push(matrix[rIdx][cIdx]);
                });
                csvContent += row.join(",") + "\n";
            });

            const encodedUri = encodeURI(csvContent);
            const link = document.createElement("a");
            link.setAttribute("href", encodedUri);
            link.setAttribute("download", `lexsurv_matrix_${activeComp.name.replace(/\s+/g, '_')}.csv`);
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        };

        return (
            <div className="flex flex-col h-full bg-slate-50">
                <div className="bg-white border-b border-slate-200 p-4 shadow-sm flex justify-between items-center shrink-0">
                    <div className="flex items-center gap-4">
                        <select
                            className="text-sm border border-slate-300 rounded px-3 py-2 bg-white font-medium text-slate-800 shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                            value={activeComp.id}
                            onChange={e => setSelectedResultsCompId(e.target.value)}
                        >
                            {comparisons.map(c => <option key={c.id} value={c.id}>{c.name} ({c.type})</option>)}
                        </select>
                        <span className="text-sm text-slate-500">Staircase Percentage Matrix</span>
                    </div>

                    <button
                        onClick={handleDownloadCSV}
                        className="flex items-center gap-2 bg-slate-800 hover:bg-slate-700 text-white px-4 py-2 rounded text-sm font-medium transition-colors shadow-sm"
                    >
                        Export to CSV
                    </button>
                </div>

                <div className="flex-1 overflow-auto p-8 flex justify-center items-start">
                    <div className="bg-white p-8 rounded-xl shadow-md border border-slate-200 overflow-x-auto">
                        <table className="border-collapse font-sans text-sm min-w-max">
                            <tbody>
                                {varieties.map((vRow, rIdx) => (
                                    <tr key={`r-${vRow.id}`}>
                                        {/* Column Headers for Staircase */}
                                        {varieties.map((vCol, cIdx) => {
                                            // Render Name Cell conceptually
                                            if (cIdx === rIdx) {
                                                return <td key={`name-${vCol.id}`} className="p-3 pr-8 font-bold text-slate-800 text-left border-b border-r border-slate-200 whitespace-nowrap">{vRow.name}</td>;
                                            }
                                            // Render Value Cell
                                            if (cIdx < rIdx) {
                                                const val = matrix[rIdx][cIdx];
                                                return <td key={`val-${vRow.id}-${vCol.id}`} className="p-3 border-b border-slate-200 text-center text-slate-600 font-medium">{val}</td>;
                                            }
                                            // Empty cell upper triangle
                                            return <td key={`empty-${vRow.id}-${vCol.id}`} className="p-3"></td>;
                                        })}
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        );
    };

    const renderContent = () => {
        switch (activeTab) {
            case 'glosses': return renderGlossesTab();
            case 'wordlists': return renderWordlistsTab();
            case 'comparisons': return renderComparisonsTab();
            case 'analysis': return renderAnalysisTab();
            case 'results': return renderResultsTab();
            default: return null;
        }
    };

    const renderRestorePrompt = () => {
        if (savedSessionStatus !== 'found') return null;
        return (
            <div className="fixed inset-0 bg-slate-900/50 z-50 flex items-center justify-center p-4">
                <div className="bg-white rounded-xl shadow-xl max-w-md w-full p-6 text-center">
                    <FolderOpen className="w-12 h-12 text-blue-500 mx-auto mb-4" />
                    <h2 className="text-xl font-bold text-slate-800 mb-2">Saved Session Found</h2>
                    <p className="text-slate-600 mb-6 font-medium">We found an auto-saved session from your last visit. Would you like to restore it?</p>
                    <div className="flex gap-4 justify-center">
                        <button onClick={discardSession} className="px-4 py-2 text-slate-600 bg-slate-100 hover:bg-slate-200 rounded-lg font-medium transition-colors">Start Fresh</button>
                        <button onClick={restoreSession} className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition-colors shadow-sm">Restore Session</button>
                    </div>
                </div>
            </div>
        );
    };

    const renderIpaPalette = () => {
        if (!ipaPaletteVisible) return null;
        return (
            <div className="fixed bottom-4 right-4 bg-white rounded-xl shadow-2xl border border-slate-200 w-80 z-40 flex flex-col overflow-hidden">
                <div className="bg-slate-800 text-white p-3 flex justify-between items-center">
                    <div className="flex items-center gap-2"><Type className="w-4 h-4" /> <span className="text-sm font-bold">IPA Palette</span></div>
                    <button onClick={() => setIpaPaletteVisible(false)} className="hover:text-red-400 transition-colors"><X className="w-4 h-4" /></button>
                </div>
                <div className="flex bg-slate-100 overflow-x-auto scrollbar-hide border-b border-slate-200 p-1">
                    {Object.keys(IPA_PALETTE).map(cat => (
                        <button
                            key={cat}
                            onClick={(e) => { e.preventDefault(); setIpaCategory(cat); }}
                            className={`px-3 py-1.5 text-xs font-semibold rounded shrink-0 transition-colors ${ipaCategory === cat ? 'bg-white shadow text-blue-700' : 'text-slate-600 hover:text-slate-900'}`}
                        >
                            {cat}
                        </button>
                    ))}
                </div>
                <div className="p-3 grid grid-cols-6 gap-2 bg-slate-50 h-64 overflow-y-auto content-start">
                    {IPA_PALETTE[ipaCategory].map((char, i) => (
                        <button
                            key={`${char}-${i}`}
                            onMouseDown={(e) => e.preventDefault()}
                            onClick={() => insertIpa(char)}
                            className="text-lg font-mono bg-white border border-slate-300 rounded pb-1 pt-0.5 hover:border-blue-500 hover:text-blue-700 hover:bg-blue-50 transition-colors shadow-sm flex items-center justify-center h-10 w-10"
                            title={char}
                        >
                            {char}
                        </button>
                    ))}
                </div>
            </div>
        );
    };

    return (
        <div className="flex flex-col min-h-screen bg-slate-50 font-sans">
            {renderRestorePrompt()}
            {renderIpaPalette()}

            {/* Header and Stats */}
            <header className="bg-white border-b border-slate-200">
                <div className="flex items-center justify-between px-6 py-4">
                    <h1 className="text-2xl font-bold text-slate-900 tracking-tight">LexSurv</h1>
                    <div className="flex items-center gap-6">
                        <div className="flex gap-4 text-sm font-medium text-slate-600 border-r border-slate-200 pr-6">
                            <span className="flex items-center gap-1"><Book className="w-4 h-4 text-slate-400" /> {glossDictionaries.length} Dicts</span>
                            <span className="flex items-center gap-1"><List className="w-4 h-4 text-slate-400" /> {surveys.length} Surveys</span>
                            <span className="flex items-center gap-1"><SplitSquareVertical className="w-4 h-4 text-slate-400" /> {varietiesCount} Vars</span>
                            <span className="flex items-center gap-1"><LineChart className="w-4 h-4 text-slate-400" /> {comparisons.length} Comps</span>
                        </div>

                        <div className="flex items-center gap-3">
                            <button onClick={() => setIpaPaletteVisible(!ipaPaletteVisible)} className={`p-2 rounded-lg transition-colors border ${ipaPaletteVisible ? 'bg-blue-50 border-blue-200 text-blue-700' : 'bg-slate-50 border-slate-200 text-slate-600 hover:bg-slate-100'}`} title="Toggle IPA Palette">
                                <Type className="w-4 h-4" />
                            </button>

                            <label className="cursor-pointer p-2 rounded-lg bg-slate-50 border border-slate-200 text-slate-600 hover:bg-slate-100 transition-colors" title="Open Project File (.json)">
                                <FolderOpen className="w-4 h-4" />
                                <input type="file" accept=".json" className="hidden" onChange={handleImportProject} />
                            </label>

                            <button onClick={handleExportProject} className="p-2 rounded-lg bg-slate-50 border border-slate-200 text-slate-600 hover:bg-slate-100 transition-colors" title="Export Project File (.json)">
                                <Download className="w-4 h-4" />
                            </button>

                            <div className="flex items-center gap-2 text-xs font-medium min-w-[120px] justify-end">
                                {hasUnsavedChanges ? (
                                    <span className="text-amber-500 flex items-center gap-1">● Unsaved</span>
                                ) : (
                                    <span className="text-green-500 flex items-center gap-1">✓ Saved {lastSavedTime ? 'locally' : ''}</span>
                                )}
                            </div>
                        </div>
                    </div>
                </div>

                {/* Navigation Tabs */}
                <div className="flex px-4 overflow-x-auto scrollbar-hide">
                    {tabs.map(tab => {
                        const isEnabled = tab.id === 'glosses' ? true :
                            tab.id === 'wordlists' ? glossDictionaries.length > 0 :
                                tab.id === 'comparisons' ? surveys.length > 0 :
                                    (tab.id === 'analysis' || tab.id === 'results') ? comparisons.length > 0 : false;
                        return (
                            <button
                                key={tab.id}
                                onClick={() => handleTabClick({ ...tab, enabled: isEnabled })}
                                disabled={!isEnabled}
                                className={`flex items-center gap-2 px-4 py-3 border-b-2 text-sm font-medium transition-colors whitespace-nowrap
                   ${!isEnabled
                                        ? 'border-transparent text-slate-300 cursor-not-allowed'
                                        : activeTab === tab.id
                                            ? 'border-blue-600 text-blue-700'
                                            : 'border-transparent text-slate-600 hover:text-slate-900 hover:border-slate-300'
                                    }`}
                            >
                                <tab.icon className="w-4 h-4" />
                                {tab.label}
                            </button>
                        );
                    })}
                </div>
            </header>

            {/* Main Content Area */}
            <main className="flex-1 bg-white mx-6 my-6 border border-slate-200 rounded-lg shadow-sm overflow-hidden">
                {renderContent()}
            </main>

            {/* State Debugger */}
            <footer className="mt-auto bg-slate-900 text-slate-300">
                <button
                    onClick={() => setShowState(!showState)}
                    className="w-full px-6 py-2 flex items-center justify-between bg-slate-800 hover:bg-slate-700 transition-colors border-t border-slate-700"
                >
                    <span className="text-sm font-semibold tracking-wider uppercase">Application State Debugger</span>
                    <span className="text-xs bg-slate-700 px-2 py-1 rounded">{showState ? 'Collapse' : 'Expand'}</span>
                </button>
                {showState && (
                    <div className="p-6 overflow-auto max-h-96">
                        <pre className="text-xs font-mono text-green-400">
                            {JSON.stringify({ glossDictionaries, surveys, comparisons }, null, 2)}
                        </pre>
                    </div>
                )}
            </footer>
        </div>
    );
}
