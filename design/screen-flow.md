Project: Patrol — Screen Flow & Wireframe Notes

Screens (Landing + A-F)

- Dashboard (Landing / Roster)
  - Stack of personnel-folder cards with tactile shadows and paper texture.
  - Quick actions: New Character, Import, Export PDF, Sync.
  - Background image placeholder: `assets/images/background.jpg` (use provided image).

- Screen A: Basic Info
  - Fields: Name, Age (starts 17), Nationality, Height (dropdown), Weight (+ unit toggle), Languages, Motivation (dropdown + custom), Background (dropdown + bonus), Trademark (dropdown + custom)

- Screen B: Enlistment
  - Select Service, Enlisted/Officer toggle, dynamic Rank ladder, Military Specialty dropdown

- Screen C: Attributes & Skills
  - Point-buy (22) and Random roll (1D10 x4) flows, re-roll and assign, descriptors live-updating

- Screen D: Deployments
  - Random/select deployment generator (1D10), per-deployment options (location, award, school), promotion rules and skill gains

- Screen E: Abilities & Narrative
  - 12 computed ability scores from defined formulas; narrative text box (800 chars) + AI generate button

- Screen F: Inventory & Appearance (Paper Doll)
  - Center interactive figure (paper-doll layers), loadout selection, locker room drag-and-drop, equipment override menu

Wireframes
- Low-fidelity SVGs included in `design/wireframes/` for Dashboard and Screens A-F.

Next steps:
- Iterate on these wireframes into high-fidelity mockups using the provided visual spec.
- Generate component library (Figma/XD) and begin Flutter scaffold implementation.
