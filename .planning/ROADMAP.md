# EBS BioCrop Science - Implementation Roadmap

## Phases
- [x] **Phase 1: Project Scaffolding & Core Architecture**
  - Dependency setup, BLoC configuration, Clean Architecture directory structure.
  - Theming derived from EBS BioCrop logo.
- [ ] **Phase 2: Professional Farmer-Centric UI & Feature Upgrade**
  - Replace all third-party benchmark brand names with **EBS BioCrop Science**.
  - Add bilingual English/Hindi subtitles and intuitive visual icons for farmers.
  - Implement interactive **Crop Doctor ("फसल डॉक्टर")** advisory diagnosis modal.
  - Implement interactive **Acreage & Dosage Calculator** modal.
  - Implement live **APMC Mandi Bhav ("दैनिक मंडी भाव")** ticker and modal.
  - Implement floating / sticky **Farmer Quick Action Bar** (Toll-Free 1800-203-1425 & WhatsApp).
  - Add CIBRC statutory toxicity triangle badges and dosage per pump on product cards.
  - Add quick clickable Technical Ingredient tags under the search bar.
- [ ] **Phase 3: Verification, Quality Assurance & Deployment**
  - Zero static analysis lints (`flutter analyze`).
  - Pass all widget and smoke tests (`flutter test`).
  - Hot reload / restart verification.
  - Git commit and push to remote `main`.
