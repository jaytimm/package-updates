# Package health report

**Overall: ❌ FAILURE**

Generated from the latest completed checks at `2026-11-19T18:47:58Z`.

## Summary

| Package | Check | Status | Seconds | Findings |
| --- | --- | --- | ---: | ---: |
| puremoe | `puremoe_pubmed_search` | ✅ OK | 0.632 | 0 |
| puremoe | `puremoe_pubmed_abstracts` | ✅ OK | 0.756 | 0 |
| puremoe | `puremoe_pubmed_affiliations` | ✅ OK | 0.752 | 0 |
| puremoe | `puremoe_icite` | ✅ OK | 0.509 | 0 |
| puremoe | `puremoe_pubtator` | ✅ OK | 0.424 | 0 |
| puremoe | `puremoe_pmc_id_converter` | ✅ OK | 0.576 | 0 |
| puremoe | `puremoe_pmc_oa_url` | ✅ OK | 1.391 | 0 |
| puremoe | `puremoe_pmc_fulltext` | ✅ OK | 1.447 | 0 |
| puremoe | `puremoe_mesh_thesaurus` | ❌ FAILURE | 231.433 | 2 |
| puremoe | `puremoe_mesh_trees` | ✅ OK | 2.022 | 0 |
| puremoe | `puremoe_local_smoke` | ✅ OK | 0.038 | 0 |
| textpress | `textpress_rss` | ✅ OK | 0.630 | 0 |
| textpress | `textpress_wikipedia_search` | ✅ OK | 0.671 | 0 |
| textpress | `textpress_wikipedia_references` | ✅ OK | 0.529 | 0 |
| textpress | `textpress_read_urls` | ✅ OK | 0.357 | 0 |
| textpress | `textpress_huggingface_embeddings` | ❌ FAILURE | 0.429 | 1 |
| textpress | `textpress_local_smoke` | ✅ OK | 0.029 | 0 |

## puremoe

### ✅ puremoe_pubmed_search

- Status: **OK**
- Package: `puremoe` `1.1.1`
- Kind: `live`
- Elapsed: `0.632` seconds
- Finished: `2026-11-19T18:47:47Z`

#### Output sample

```json
["43054430", "43054031", "43053233"]
```

### ✅ puremoe_pubmed_abstracts

- Status: **OK**
- Package: `puremoe` `1.1.1`
- Kind: `live`
- Elapsed: `0.756` seconds
- Finished: `2026-11-19T18:47:48Z`

#### Output sample

```json
{
  "pmid": ["38136652", "11250746"],
  "doi": ["10.3390/biom13121783", "10.1186/bcr271"],
  "year": [2023, 2001],
  "pubtype": ["Journal Article | Review | Research Support, Non-U.S. Gov't", "Comparative Study | Journal Article"],
  "journal": ["Biomolecules", "Breast cancer research : BCR"],
  "articletitle": ["Ethnobotany, Phytochemistry, and Biological Activities of the Genus Cordyline.", "Comparison of written reports of mammography, sonography and magnetic resonance mammography for preoperative evaluation of breast lesions, with special emphasis on magnetic resonance mammography."],
  "abstract": ["Cordyline species have a long history in traditional medicine as a basis of treatment for various ailments such as a bloody cough, dysentery, and a high fever. There are about 26 accepted species names in this genus distributed worldwide, including C. fruticosa, C. autralis, C. stricta, C. cannifolia, and C. dracaenosides. This work presents a comprehensive review of the traditional uses of plants of the genus Cordylie and their chemical constituents and biological activities. A bibliographic search was conducted to identify available information on ethnobotany, ethnopharmacology, chemical composition, and biological activities. A total of 98 isolated compounds potentially responsible for most of the traditional medicinal applications have been reported from eight species of Cordyline and are characterised as flavonoid, spirostane, furostane, and cholestane glycosides. Some of these pure compounds, as well as extracts from some species of Cordyline, have exhibited noteworthy anti-oxidant, antiproliferative, antimicrobial, and hypolipidemic activities. Although many of these species have not yet been investigated phytochemically or pharmacologically, they remain a potential source of new bioactive compounds.", "Patients with abnormal breast findings (n = 413) were examined by mammography, sonography and magnetic resonance (MR) mammography; 185 invasive cancers, 38 carcinoma in situ and 254 benign tumours were confirmed histologically. Sensitivity for mammography was 83.7%, for sonography it was 89.1% and for MR mammography it was 94.6% for invasive cancers. In 42 patients with multifocal invasive cancers, multifocality had been detected by mammography and sonography in 26.2%, and by MR mammography in 66.7%. In nine patients with multicentric cancers, detection rates were 55.5, 55.5 and 88.8%, respectively. Carcinoma in situ was diagnosed by mammography in 78.9% and by MR mammography in 68.4% of patients. Combination of all three diagnostic methods lead to the best results for detection of invasive cancer and multifocal disease. However, sensitivity of mammography and sonography combined was identical to that of MR mammography (i.e., 94.6%)."],
  "annotations": ["'data.frame':\t12 obs. of  4 variables:  $ pmid          : chr  \"38136652\" \"38136652\" \"38136652\" \"38136652\" ...  $ type          : chr  \"MeSH\" \"MeSH\" \"MeSH\" \"MeSH\" ...  $ DescriptorName: chr  \"Ethnobotany\" \"Phytotherapy\" \"Cordyline\" \"Phytochemicals\" ...  $ DescriptorUI  : chr  \"D019448\" \"D008517\" \"D031406\" \"D064209\" ...", "'data.frame':\t10 obs. of  4 variables:  $ pmid          : chr  \"11250746\" \"11250746\" \"11250746\" \"11250746\" ...  $ type          : chr  \"MeSH\" \"MeSH\" \"MeSH\" \"MeSH\" ...  $ DescriptorName: chr  \"Breast Neoplasms\" \"Diagnostic Imaging\" \"Female\" \"Humans\" ...  $ DescriptorUI  : chr  \"D001943\" \"D003952\" \"D005260\" \"D006801\" ..."]
}
```

### ✅ puremoe_pubmed_affiliations

- Status: **OK**
- Package: `puremoe` `1.1.1`
- Kind: `live`
- Elapsed: `0.752` seconds
- Finished: `2026-11-19T18:47:48Z`

#### Output sample

```json
{
  "pmid": ["38136652", "38136652", "38136652"],
  "Author": ["Tematio Fouedjou, Romuald", "Tsakem, Bienvenu", "Siwe-Noundou, Xavier"],
  "Affiliation": ["Research Unit of Environmental and Applied Chemistry, Department of Chemistry, Faculty of Science, University of Dschang, Dschang P.O. Box 67, Cameroon.", "Research Unit of Environmental and Applied Chemistry, Department of Chemistry, Faculty of Science, University of Dschang, Dschang P.O. Box 67, Cameroon.", "Department of Pharmaceutical Sciences, School of Pharmacy, Sefako Makgatho Health Sciences University, P.O. Box 218, Pretoria 0208, South Africa."]
}
```

### ✅ puremoe_icite

- Status: **OK**
- Package: `puremoe` `1.1.1`
- Kind: `live`
- Elapsed: `0.509` seconds
- Finished: `2026-11-19T18:47:49Z`

#### Output sample

```json
{
  "pmid": ["11250746", "38136652"],
  "citation_count": [70, 6],
  "relative_citation_ratio": [2.313, 0.881],
  "nih_percentile": [77.5, 45.8],
  "field_citation_rate": [3.7554, 5.5967],
  "is_research_article": [true, false],
  "is_clinical": [false, false],
  "provisional": [false, false]
}
```

### ✅ puremoe_pubtator

- Status: **OK**
- Package: `puremoe` `1.1.1`
- Kind: `live`
- Elapsed: `0.424` seconds
- Finished: `2026-11-19T18:47:49Z`

#### Output sample

```json
{
  "entities": {
    "pmid": ["11250746", "11250746", "11250746"],
    "mention_index": [0, 1, 2],
    "id": ["1", "15", "16"],
    "text": ["breast lesions", "Patients", "invasive cancers"],
    "type": ["Disease", "Species", "Disease"],
    "identifier": ["MESH:D061325", "9606", "MESH:D009362"],
    "tiab": ["title", "abstract", "abstract"],
    "start": [123, 196, 331]
  },
  "relations": {
    "pmid": [],
    "relation_id": [],
    "relation_type": [],
    "score": [],
    "ent1_mention_index": [],
    "ent1_type": [],
    "ent2_mention_index": [],
    "ent2_type": []
  }
}
```

### ✅ puremoe_pmc_id_converter

- Status: **OK**
- Package: `puremoe` `1.1.1`
- Kind: `live`
- Elapsed: `0.576` seconds
- Finished: `2026-11-19T18:47:50Z`

#### Output sample

```json
{
  "pmid": ["11250746", "11573492"],
  "pmcid": ["PMC13900", "PMC1121146"],
  "doi": ["10.1186/bcr271", "10.1136/bmj.323.7312.574"]
}
```

### ✅ puremoe_pmc_oa_url

- Status: **OK**
- Package: `puremoe` `1.1.1`
- Kind: `live`
- Elapsed: `1.391` seconds
- Finished: `2026-11-19T18:47:51Z`

#### Output sample

```json
{
  "pmid": "11250746",
  "pmcid": "PMC13900",
  "doi": "10.1186/bcr271",
  "url": "https://pmc-oa-opendata.s3.amazonaws.com/PMC13900.1/PMC13900.1.xml"
}
```

### ✅ puremoe_pmc_fulltext

- Status: **OK**
- Package: `puremoe` `1.1.1`
- Kind: `live`
- Elapsed: `1.447` seconds
- Finished: `2026-11-19T18:47:53Z`

#### Output sample

```json
{
  "pmid": ["11250746", "11250746", "11250746"],
  "section": ["Introduction", "Patients and methods", "Results"],
  "text": ["Mammography and sonography are the standard imaging techniques for detection and evaluation of breast disease [ 1 ]. Mammography is the most established screening modality [ 2 ]. Especially in young women and women with dense breasts, sonography appears superior to mammography, and differentiation between solid tumours and cysts is easier. Sensitivity and specificity of sonography or mammography are higher if sonography and mammography are combined [ 3 ]. It is generally accepted that MR mammography is the most sensitive technique for diagnosis of breast cancer, whereas the reported specificity of MR mammography varies [ 4 , 5 , 6 , 7 , 8 , 9 , 10 , 11 , 12 ]. In those studies, MR mammography was performed and evaluated by highly specialized radiologists in a research setting. It was therefore the purpose of the present prospective study to compare the validity of MR mammography with mammography and sonography in clinical routine practice. Findings for the three diagnostic methods documented on routine reports that were available to the surgeon preoperatively formed the basis of this comparison. Special emphasis was placed on the identification of multifocal and multicentric invasive disease.", "Patients Between September 1995 and September 1998, 413 patients with abnormal breast findings were referred for histological evaluation to the Department of Gynecology of the Friedrich-Schiller University, Jena, Germany. Patients had been selected and referred because of the presence of breast lesions detected by palpation and/or mammography and/or sonography. In addition, MR mammography was performed in all patients. We excluded five patients with invasive cancer who had a history of core-needle or fine-needle biopsy cancer within 2 weeks before referral, because the presence of haematoma may mimic false-positive findings on MR mammography. In addition, five patients who did not keep still during MR mammography were excluded. Imaging Analysis of the sonograms taken in patients with histologically confirmed carcinoma in situ were excluded from analysis because the value of sonography for detection of premalignant disease is limited. Mammography was not performed in 32 patients who were younger than 30 years or who had had a mastectomy with suspected local recurrence. For all patients, written reports of mammographic, sonographic and dynamic MR mammographic findings were available preoperatively. The majority of mammograms (68%) were performed at the Institute for Diagnostic and Interventional Radiology, Friedrich-Schiller-University, using a senograph DMR (GE Medical Systems, Milwaukee, Wisconsin, USA) with standard craniocaudal and mediolateral oblique projections. Mammograms obtained at other institutions that were considered to match the quality standards of our institution were also accepted for evaluation. All sonography and MR examinations were carried out at the Department of Gynecology and the Institute for Diagnostic Interventional Radiology, Friedrich-Schiller-University, respectively. Sonography was done using a 7.5-MHz linear array probe with a Sonoline Versa Pro (Siemens, Erlangen, Germany). MR mammography was performed exclusively at the Institute for Diagnostic Interventional Radiology, using a Gyroscan ACSII (Philips, Nijmegen, The Netherlands) with a field strength of 1.5 T using a double-breast coil. Dynamic T1-weighted images were aquired using a multislice two-dimensional fast-field-echo (FFE) sequence. We used the following parameters: TR 97, TE 5.0, flip angle 80°, slice thickness 4.0 mm, gap 0.4 mm, field of view 350 mm and transverse orientation. In addition T2-weighted images (4000/300/90°/4.0 mm/0.4/350 mm) were obtained. As contrast medium, 0.1 mmol gadolinium-DTPA/kg body weight (Magnevist; Schering, Berlin, Germany) was used and injected as a bolus. One unenhanced and seven enhanced studies were acquired with an acquisition time of 1 min. Criteria for malignancy were signal enhancement of 90% or more within the first 2 min after bolus injection and signal plateau or washout phenomena afterward. Additional criteria were irregular borders of the lesion and low signal intensity in the T2-weighted images. Mammograms were read by three different radiologists, sonography was done by three different gynaecologists and MR mammography was interpreted by a total of six different radiologists. Definition for multifocal carcinoma was a distance of less than 3 cm and for multicentric carcinoma a distance over 3 cm between various lesions. Statistical analysis Interpretation of the various diagnostic procedures was compared with the histological examination with regard to sensitivity, specificity, accuracy, and positive and negative predictive value. Criteria for suspected malignancy in the written reports were the terms 'cancer', 'malignant lesion or tumor', or 'suspicious for cancer'. Sensitivity, specificity, negative and positive predicitive value, and accuracy were evaluated as follows: Sensitivity = patients with suspected breast cancer/patients with histologically confirmed breast cancer Specificity = patients with suspected benign disease/patients with histologically confirmed benign disease Positive predictive value = patients with histologically confirmed breast cancer/patients with suspected breast cancer Negative predictive value = patients with histologically confirmed benign disease/patients with suspected benign disease Accuracy = patients with true-positive and true-negative detected disease/patients with histologically confirmed breast cancer A result was classified as false-negative when a diagnostic method classified a histologically confirmed cancer as benign. A result was classified as false-positive when a diagnostic method classified a histologically confirmed benign lesion as cancer. We compared the preformance of all diagnostic methods individually and in combination using the results from all patients. Statistical analysis was performed for all variables with Fisher's exact test and Pearson's χ 2 test.", "All patients underwent breast surgery and all abnormal lesions identified by mammography, sonography or MR mammography were surgically removed. A total of 477 breast lesions were examined histologically, revealing the presence of 185 invasive cancers, 38 carcinomata in situ and 254 benign lesions (fibroadenoma, papilloma, intraductal or adenoid ductal hyperplasia, cystic mastopathia). There were four patients with malignant lesions in both breasts. In 42 patients multifocal tumours and in nine patients multicentric tumors were found on histological examination. Among the 185 invasive lesions, 178 were primary cancers, five were recurrences, one was metastatic and one was an angiosarcoma. The majority of invasive breast cancers were staged as pT1c (44%). Six per cent of tumors were detected in stage pT1a, 18% in stage pT1b, 25% in stage pT2, 3% in stage pT3 and 4% in stage pT4. The distribution of histopathological tumour types is shown in Table 1 . The mean age of patients was 58 years (range 19-85 years). The sensitivity of MR mammography was significantly higher than those of mammography and sonography ( P < 0.005 and P < 0.05; Table 2 ). The specificity of sonography was significantly higher than those of mammography and MR mammography ( P < 0.05 and P < 0.005; Table 2 ). The negative predictive values for sonography and MR mammography were significantly higher than that of mammography ( P < 0.05 and P < 0.005; Table 2 ). With regard to accuracy, no significant difference between the three modalities was found (Table 2 ). Combining of all three diagnostic methods yielded the best results for detection of cancer ( P < 0.005; Table 3 ). The sensitivity and negative predictive value for the combination of mammography and MR mammography, and the combination of sonography and MR mammography were significantly higher than those for the combination of mammograpy and sonography ( P < 0.05; Table 3 ). The highest result for accuracy was seen for a combination of all three methods ( P < 0.05; Table 3 ). Mammography was false-negative in 30 out of 184 invasive cancers, sonography was false-negative in 20 out of 185 cancers, and 10 out of 185 invasive cancers were missed by MR mammography. The majority of false-negative findings was found in stage1 disease, ductal carcinoma and grade 3 tumors (Table 4 ). Of 10 invasive cancers missed by MR mammography, eight were found by mammography and sonography. By all three techniques, one invasive ductal carcinoma (pT1b) was misinterpreted as fibroadenoma. In another patient, a microinvasive lobular carcinoma of 5 mm diameter was not detected with mammography and MR mammography, whereas sonography detected a solid, benign tumour. MR mammography identified 10 invasive cancers (5.2%) that were missed by mammography and sonography, whereas one invasive cancer was found by mammography alone. By sonography alone, not a single case of invasive disease was detected when MR mammography or mammography were nonsuspected. The highest detection rate for multifocal invasive disease was seen with MR mammography, which identified 28 out of 42 (66.7%) histologically confirmed multifocal invasive cancers, whereas mammography and sonography both identified 11 (26.2%) of these cancers ( P < 0.05). The combination of all three diagnostic methods leads to the best result for detection of multifocality (76.2%; P < 0.05), whereas the detection rate with the combination of mammography and sonography was 35.7%, with the combination of sonography and MR mammography it was 69% ( P < 0.05 versus mammography + sonography), and with the combination of mammography and MR mammography it was 73.8% ( P < 0.05 versus mammography + sonography). Multifocal invasive disease was suspected in 12 patients by mammography, in 13 patients by sonography, and in 16 patients by MR mammography, but only unifocal disease was confirmed by histology. Out of nine patients with histologically confirmed multicentric invasive cancer, eight (88.8%) of these cancers were detected by MR mammography and five (55.5%) by mammography or sonography. One patient was diagnosed with multicentric invasive-lobular carcinoma stage pT2G2, which had been misinterpreted as benign tumour by sonography and mammography, and as haematoma by MR mammography. Out of 38 patients with carcinoma in situ , mammography (suspicious microcalcifications, exclusively) identified 30 cases (78.9%) and MR mammography identified 26 cases (68.4%). When combining mammography and MR mammography, sensitivity for detection of carcinoma in situ increased to 87% (not significant)."]
}
```

### ❌ puremoe_mesh_thesaurus

- Status: **FAILURE**
- Package: `puremoe` `1.1.1`
- Kind: `live`
- Elapsed: `231.433` seconds
- Finished: `2026-11-19T18:23:11Z`

#### Error

`error reading from connection`

#### Findings

| Severity | Code | Path | Message |
| --- | --- | --- | --- |
| warning | `slow_response` | `root` | Check took 231.433 seconds; warning threshold is 90.000 seconds. |

#### Output sample

_No sample available._

### ✅ puremoe_mesh_trees

- Status: **OK**
- Package: `puremoe` `1.1.1`
- Kind: `live`
- Elapsed: `2.022` seconds
- Finished: `2026-11-19T18:47:55Z`

#### Output sample

```json
{
  "DescriptorUI": ["D000001", "D000001", "D000001"],
  "DescriptorName": ["Calcimycin", "Calcimycin", "Calcimycin"],
  "tree_location": ["D02.355.291.933.125", "D02.540.576.625.125", "D03.633.100.221.173"],
  "code": ["D", "D", "D"],
  "cats": ["Chemicals and Drugs", "Chemicals and Drugs", "Chemicals and Drugs"],
  "mesh1": ["Organic Chemicals", "Organic Chemicals", "Heterocyclic Compounds"],
  "mesh2": ["Ethers", "Lactones", "Heterocyclic Compounds, Fused-Ring"],
  "tree1": ["D02", "D02", "D03"]
}
```

### ✅ puremoe_local_smoke

- Status: **OK**
- Package: `puremoe` `1.1.1`
- Kind: `local`
- Elapsed: `0.038` seconds
- Finished: `2026-11-19T18:47:55Z`

#### Output sample

```json
{
  "endpoints": ["pubmed_abstracts", "pubmed_affiliations", "icites"],
  "snowball": {
    "pmid": ["1", "2", "100"],
    "seed": [true, true, false],
    "cited_links": [null, null, 2],
    "citing_links": [null, null, 0],
    "link_count": [null, null, 2]
  },
  "keyness": {
    "DescriptorUI": "D1",
    "DescriptorName": "Alpha",
    "corpus_count": 2,
    "corpus_total": 2,
    "corpus_prop": 1,
    "baseline_count": 1000,
    "baseline_total": 1000000,
    "baseline_prop": 0.001
  }
}
```


## textpress

### ✅ textpress_rss

- Status: **OK**
- Package: `textpress` `1.1.2`
- Kind: `live`
- Elapsed: `0.630` seconds
- Finished: `2026-11-19T18:47:55Z`

#### Output sample

```json
{
  "doc_id": [1, 2, 3],
  "url": ["https://www.politico.com/live-updates/2026/11/19/congress/tim-scott-banking-hearing-bessent-lutnick-01175875", "https://www.politico.com/live-updates/2026/11/19/congress/cisa-michael-losapio-hearing-2020-election-01175841", "https://www.politico.com/live-updates/2026/11/19/congress/bipartisan-trio-unveils-new-ai-safety-framework-01175648"],
  "title": ["Tim Scott open to joint Bessent-Lutnick testimony on China chips", "Trump’s CISA nominee dodges questions on who won the 2020 election and whether Jan. 6 was an insurrection", "Bipartisan trio unveils new AI safety framework"],
  "published_at": ["2026-11-19 13:31:18", "2026-11-19 13:20:03", "2026-11-19 12:46:18"],
  "source": ["www.politico.com", "www.politico.com", "www.politico.com"],
  "language": [null, null, null],
  "country": [null, null, null],
  "feed_url": ["https://rss.politico.com/congress.xml", "https://rss.politico.com/congress.xml", "https://rss.politico.com/congress.xml"]
}
```

### ✅ textpress_wikipedia_search

- Status: **OK**
- Package: `textpress` `1.1.2`
- Kind: `live`
- Elapsed: `0.671` seconds
- Finished: `2026-11-19T18:47:56Z`

#### Output sample

```json
["https://en.wikipedia.org/wiki/Doxorubicin", "https://en.wikipedia.org/wiki/Biosynthesis_of_doxorubicin", "https://en.wikipedia.org/wiki/Zoptarelin_doxorubicin"]
```

### ✅ textpress_wikipedia_references

- Status: **OK**
- Package: `textpress` `1.1.2`
- Kind: `live`
- Elapsed: `0.529` seconds
- Finished: `2026-11-19T18:47:57Z`

#### Output sample

```json
{
  "source_url": ["https://en.wikipedia.org/wiki/Doxorubicin", "https://en.wikipedia.org/wiki/Doxorubicin", "https://en.wikipedia.org/wiki/Doxorubicin"],
  "ref_id": ["cite_note-Caelyx_pegylated_liposomal_EPAR-1", "cite_note-Myocet_liposomal_EPAR-2", "cite_note-Zolsketil_pegylated_liposomal_EPAR-3"],
  "ref_url": ["https://web.archive.org/web/20220621052132/https://www.ema.europa.eu/en/medicines/human/EPAR/caelyx-pegylated-liposomal", "https://web.archive.org/web/20220225004945/https://www.ema.europa.eu/en/medicines/human/EPAR/myocet-liposomal-previously-myocet", "https://web.archive.org/web/20220621052452/https://www.ema.europa.eu/en/medicines/human/EPAR/zolsketil-pegylated-liposomal"]
}
```

### ✅ textpress_read_urls

- Status: **OK**
- Package: `textpress` `1.1.2`
- Kind: `live`
- Elapsed: `0.357` seconds
- Finished: `2026-11-19T18:47:57Z`

#### Output sample

```json
{
  "text": {
    "doc_id": [1, 1, 1],
    "url": ["https://en.wikipedia.org/wiki/Doxorubicin", "https://en.wikipedia.org/wiki/Doxorubicin", "https://en.wikipedia.org/wiki/Doxorubicin"],
    "node_id": [1, 2, 3],
    "parent_heading": ["Doxorubicin", "Doxorubicin", "Doxorubicin"],
    "text": ["Doxorubicin, sold under the brand name Adriamycin among others, is a chemotherapy medication used to treat cancer.[10] This includes breast cancer, bladder cancer, Kaposi's sarcoma, lymphoma, and acute lymphocytic leukemia.[10] It is often used together with other chemotherapy agents.[10] Doxorubicin is given by injection into a vein.[10]", "Common side effects include hair loss, bone marrow suppression, vomiting, rash, and inflammation of the mouth.[10] Other serious side effects may include allergic reactions such as anaphylaxis, heart damage, tissue damage at the site of injection, radiation recall, and treatment-related leukemia.[10] People often experience red discoloration of the urine for a few days.[10] Doxorubicin is in the anthracycline and antitumor antibiotic family of medications.[10] It works in part by interfering with the function of DNA.[11]", "Doxorubicin was approved for medical use in the United States in 1974.[10] It is on the World Health Organization's List of Essential Medicines.[12][13] Versions that are pegylated and in liposomes are also available; however, they are more expensive.[13] Doxorubicin was originally made from the bacterium Streptomyces peucetius.[14]"]
  },
  "meta": {
    "doc_id": 1,
    "url": "https://en.wikipedia.org/wiki/Doxorubicin",
    "h1_title": "Doxorubicin",
    "date": null,
    "source": "en.wikipedia.org"
  }
}
```

### ❌ textpress_huggingface_embeddings

- Status: **FAILURE**
- Package: `textpress` `1.1.2`
- Kind: `live`
- Elapsed: `0.429` seconds
- Finished: `2026-11-19T18:47:57Z`

#### Error

`API Error (402): {"error":"Purchase pre-paid credits to continue using Inference Providers. Alternatively, subscribe to PRO to get monthly included credits."}`

#### Output sample

_No sample available._

### ✅ textpress_local_smoke

- Status: **OK**
- Package: `textpress` `1.1.2`
- Kind: `local`
- Elapsed: `0.029` seconds
- Finished: `2026-11-19T18:47:58Z`

#### Output sample

```json
{
  "sentences": {
    "doc_id": [1, 1],
    "sentence_id": ["1", "2"],
    "text": ["Dr. Smith's well-known work. ", "They've re-tested it."],
    "start": [1, 30],
    "end": [29, 50],
    "uid": [1, 1]
  },
  "tokens": {
    "id": ["1.1", "1.1", "1.1"],
    "token": ["Dr", ".", "Smith"],
    "start": [1, 3, 5],
    "end": [2, 3, 9]
  },
  "regex": {
    "id": "1",
    "doc_id": 1,
    "text": "They've <b>re-tested<\/b> it.",
    "start": 9,
    "end": 17,
    "pattern": "re-tested"
  }
}
```


---

Generated by the central package monitoring repository.
