class NationalityData {
  static const List<String> nationalities = [
    'USA',
    'United Kingdom',
    'France',
    'Canada',
    'Norway',
    'Dutch',
    'Australian',
    'German',
    'Spain',
    'The Philippines',
    'Polish',
    'Sweden',
    'Brazil',
    'New Zealand',
    'Panama',
  ];

  static Map<String, List<String>> getEnlistedRanks(String nationality) {
    switch (nationality) {
      case 'USA':
        return {
          'ranks': [
            'Private (E-1)',
            'Private First Class (E-2)',
            'Lance Corporal (E-3)',
            'Corporal (E-4)',
            'Sergeant (E-5)',
            'Staff Sergeant (E-6)',
            'Gunnery Sergeant (E-7)',
            'Master Sergeant (E-8)',
            'First Sergeant (E-8)',
            'Sergeant Major (E-9)',
          ],
        };
      case 'United Kingdom':
        return {
          'ranks': [
            'Private',
            'Lance Corporal',
            'Corporal',
            'Sergeant',
            'Colour Sergeant',
            'Staff Sergeant',
            'Warrant Officer Class 2',
            'Warrant Officer Class 1',
          ],
        };
      case 'France':
        return {
          'ranks': [
            'Soldat',
            'Caporal',
            'Caporal-Chef',
            'Sergent',
            'Sergent-Chef',
            'Adjudant',
            'Adjudant-Chef',
            'Major',
          ],
        };
      case 'Canada':
        return {
          'ranks': [
            'Private',
            'Corporal',
            'Master Corporal',
            'Sergeant',
            'Warrant Officer',
            'Master Warrant Officer',
            'Chief Warrant Officer',
          ],
        };
      case 'Norway':
        return {
          'ranks': [
            'Menig',
            'Korporal',
            'Sersjant',
            'Førstsersjant',
            'Stabssersjant',
            'Fenrik',
          ],
        };
      case 'Dutch':
        return {
          'ranks': [
            'Soldaat',
            'Korporaal',
            'Korporaal der eerste klasse',
            'Sergeant',
            'Sergeant-majoor',
            'Adjudant-onderofficier',
          ],
        };
      case 'Australian':
        return {
          'ranks': [
            'Private',
            'Private Proficient',
            'Lance Corporal',
            'Corporal',
            'Sergeant',
            'Staff Sergeant',
            'Warrant Officer Class 2',
            'Warrant Officer Class 1',
          ],
        };
      case 'German':
        return {
          'ranks': [
            'Schütze',
            'Gefreiter',
            'Obergefreiter',
            'Hauptgefreiter',
            'Stabsgefreiter',
            'Unteroffizier',
            'Stabsunteroffizier',
            'Feldwebel',
            'Oberfeldwebel',
            'Hauptfeldwebel',
            'Stabsfeldwebel',
          ],
        };
      case 'Spain':
        return {
          'ranks': [
            'Soldado',
            'Cabo',
            'Cabo Primero',
            'Cabo Mayor',
            'Sargento',
            'Sargento Primero',
            'Brigada',
            'Suboficial Mayor',
          ],
        };
      case 'The Philippines':
        return {
          'ranks': [
            'Private',
            'Private First Class',
            'Corporal',
            'Sergeant',
            'Staff Sergeant',
            'Technical Sergeant',
            'Master Sergeant',
            'First Sergeant',
            'Sergeant Major',
          ],
        };
      case 'Polish':
        return {
          'ranks': [
            'Szeregowy',
            'Starszy Szeregowy',
            'Kapral',
            'Starszy Kapral',
            'Plutonowy',
            'Sierżant',
            'Starszy Sierżant',
            'Młodszy Chorąży',
            'Chorąży',
            'Starszy Chorąży',
          ],
        };
      case 'Sweden':
        return {
          'ranks': [
            'Menig',
            'Korpral',
            'Furir',
            'Sergeant',
            'Förste Sergeant',
            'Kompanisergeant',
            'Regementsergeant',
            'Förvaltare',
            'Fanjunkare',
          ],
        };
      case 'Brazil':
        return {
          'ranks': [
            'Soldado',
            'Cabo',
            'Terceiro-Sargento',
            'Segundo-Sargento',
            'Primeiro-Sargento',
            'Subtenente',
          ],
        };
      case 'New Zealand':
        return {
          'ranks': [
            'Private',
            'Lance Corporal',
            'Corporal',
            'Sergeant',
            'Staff Sergeant',
            'Warrant Officer Class 2',
            'Warrant Officer Class 1',
          ],
        };
      case 'Panama':
        return {
          'ranks': [
            'Agente',
            'Agente Distinguido',
            'Cabo',
            'Sargento Segundo',
            'Sargento Primero',
            'Suboficial',
            'Suboficial Mayor',
          ],
        };
      default:
        return {
          'ranks': ['Private (E-1)', 'Corporal (E-4)', 'Sergeant (E-5)'],
        };
    }
  }

  static Map<String, List<String>> getOfficerRanks(String nationality) {
    switch (nationality) {
      case 'USA':
        return {
          'ranks': [
            '2nd Lieutenant (O-1)',
            '1st Lieutenant (O-2)',
            'Captain (O-3)',
            'Major (O-4)',
            'Lieutenant Colonel (O-5)',
            'Colonel (O-6)',
          ],
        };
      case 'United Kingdom':
        return {
          'ranks': [
            '2nd Lieutenant',
            'Lieutenant',
            'Captain',
            'Major',
            'Lieutenant Colonel',
            'Colonel',
          ],
        };
      case 'France':
        return {
          'ranks': [
            'Sous-Lieutenant',
            'Lieutenant',
            'Capitaine',
            'Commandant',
            'Lieutenant-Colonel',
            'Colonel',
          ],
        };
      case 'Canada':
        return {
          'ranks': [
            'Second Lieutenant',
            'Lieutenant',
            'Captain',
            'Major',
            'Lieutenant-Colonel',
            'Colonel',
          ],
        };
      case 'Norway':
        return {
          'ranks': [
            'Fenrik',
            'Løytnant',
            'Kaptein',
            'Major',
            'Oberstløytnant',
            'Oberst',
          ],
        };
      case 'Dutch':
        return {
          'ranks': [
            'Tweede luitenant',
            'Eerste luitenant',
            'Kapitein',
            'Majoor',
            'Luitenant-kolonel',
            'Kolonel',
          ],
        };
      case 'Australian':
        return {
          'ranks': [
            'Second Lieutenant',
            'Lieutenant',
            'Captain',
            'Major',
            'Lieutenant Colonel',
            'Colonel',
          ],
        };
      case 'German':
        return {
          'ranks': [
            'Leutnant',
            'Oberleutnant',
            'Hauptmann',
            'Major',
            'Oberstleutnant',
            'Oberst',
          ],
        };
      case 'Spain':
        return {
          'ranks': [
            'Alférez',
            'Teniente',
            'Capitán',
            'Comandante',
            'Teniente Coronel',
            'Coronel',
          ],
        };
      case 'The Philippines':
        return {
          'ranks': [
            'Second Lieutenant',
            'First Lieutenant',
            'Captain',
            'Major',
            'Lieutenant Colonel',
            'Colonel',
          ],
        };
      case 'Polish':
        return {
          'ranks': [
            'Podporucznik',
            'Porucznik',
            'Kapitan',
            'Major',
            'Podpułkownik',
            'Pułkownik',
          ],
        };
      case 'Sweden':
        return {
          'ranks': [
            'Fänrik',
            'Löjtnant',
            'Kapten',
            'Major',
            'Överstelöjtnant',
            'Överste',
          ],
        };
      case 'Brazil':
        return {
          'ranks': [
            'Aspirante-a-Oficial',
            'Segundo-Tenente',
            'Primeiro-Tenente',
            'Capitão',
            'Major',
            'Tenente-Coronel',
            'Coronel',
          ],
        };
      case 'New Zealand':
        return {
          'ranks': [
            'Second Lieutenant',
            'Lieutenant',
            'Captain',
            'Major',
            'Lieutenant Colonel',
            'Colonel',
          ],
        };
      case 'Panama':
        return {
          'ranks': [
            'Subteniente',
            'Teniente',
            'Capitán',
            'Mayor',
            'Teniente Coronel',
            'Coronel',
            'Comisionado',
          ],
        };
      default:
        return {
          'ranks': ['2nd Lieutenant (O-1)', 'Captain (O-3)', 'Major (O-4)'],
        };
    }
  }

  // Get only initial entry-level ranks for character creation
  static Map<String, List<String>> getInitialEnlistedRanks(String nationality) {
    switch (nationality) {
      case 'USA':
        return {
          'ranks': [
            'Private (E-1)',
            'Private First Class (E-2)',
            'Lance Corporal (E-3)',
            'Corporal (E-4)',
          ],
        };
      case 'United Kingdom':
        return {
          'ranks': ['Private', 'Lance Corporal'],
        };
      case 'France':
        return {
          'ranks': ['Soldat', 'Caporal'],
        };
      case 'Canada':
        return {
          'ranks': ['Private', 'Corporal'],
        };
      case 'Norway':
        return {
          'ranks': ['Menig', 'Korporal'],
        };
      case 'Dutch':
        return {
          'ranks': ['Soldaat', 'Korporaal'],
        };
      case 'Australian':
        return {
          'ranks': ['Private', 'Private Proficient', 'Lance Corporal'],
        };
      case 'German':
        return {
          'ranks': ['Schütze', 'Gefreiter', 'Obergefreiter'],
        };
      case 'Spain':
        return {
          'ranks': ['Soldado', 'Cabo'],
        };
      case 'The Philippines':
        return {
          'ranks': ['Private', 'Private First Class', 'Corporal'],
        };
      case 'Polish':
        return {
          'ranks': ['Szeregowy', 'Starszy Szeregowy', 'Kapral'],
        };
      case 'Sweden':
        return {
          'ranks': ['Menig', 'Korpral', 'Furir'],
        };
      case 'Brazil':
        return {
          'ranks': ['Soldado', 'Cabo', 'Terceiro-Sargento'],
        };
      case 'New Zealand':
        return {
          'ranks': ['Private', 'Lance Corporal', 'Corporal'],
        };
      case 'Panama':
        return {
          'ranks': ['Agente', 'Agente Distinguido', 'Cabo'],
        };
      default:
        return {
          'ranks': [
            'Private (E-1)',
            'Private First Class (E-2)',
            'Corporal (E-4)',
          ],
        };
    }
  }

  // Get only initial entry-level officer ranks for character creation
  static Map<String, List<String>> getInitialOfficerRanks(String nationality) {
    switch (nationality) {
      case 'USA':
        return {
          'ranks': ['2nd Lieutenant (O-1)', '1st Lieutenant (O-2)'],
        };
      case 'United Kingdom':
        return {
          'ranks': ['2nd Lieutenant', 'Lieutenant'],
        };
      case 'France':
        return {
          'ranks': ['Sous-Lieutenant', 'Lieutenant'],
        };
      case 'Canada':
        return {
          'ranks': ['Second Lieutenant', 'Lieutenant'],
        };
      case 'Norway':
        return {
          'ranks': ['Fenrik', 'Løytnant'],
        };
      case 'Dutch':
        return {
          'ranks': ['Tweede luitenant', 'Eerste luitenant'],
        };
      case 'Australian':
        return {
          'ranks': ['Second Lieutenant', 'Lieutenant'],
        };
      case 'German':
        return {
          'ranks': ['Leutnant', 'Oberleutnant'],
        };
      case 'Spain':
        return {
          'ranks': ['Alférez', 'Teniente'],
        };
      case 'The Philippines':
        return {
          'ranks': ['Second Lieutenant', 'First Lieutenant'],
        };
      case 'Polish':
        return {
          'ranks': ['Podporucznik', 'Porucznik'],
        };
      case 'Sweden':
        return {
          'ranks': ['Fänrik', 'Löjtnant'],
        };
      case 'Brazil':
        return {
          'ranks': ['Aspirante-a-Oficial', 'Segundo-Tenente'],
        };
      case 'New Zealand':
        return {
          'ranks': ['Second Lieutenant', 'Lieutenant'],
        };
      case 'Panama':
        return {
          'ranks': ['Subteniente', 'Teniente'],
        };
      default:
        return {
          'ranks': ['2nd Lieutenant (O-1)', '1st Lieutenant (O-2)'],
        };
    }
  }

  // Get Navy enlisted ranks
  static Map<String, List<String>> getNavyEnlistedRanks(String nationality) {
    switch (nationality) {
      case 'USA':
        return {
          'ranks': [
            'Seaman Recruit (E-1)',
            'Seaman Apprentice (E-2)',
            'Seaman (E-3)',
            'Petty Officer 3rd Class (E-4)',
            'Petty Officer 2nd Class (E-5)',
            'Petty Officer 1st Class (E-6)',
            'Chief Petty Officer (E-7)',
            'Senior Chief Petty Officer (E-8)',
            'Master Chief Petty Officer (E-9)',
          ],
        };
      case 'United Kingdom':
        return {
          'ranks': [
            'Able Rate',
            'Leading Rate',
            'Petty Officer',
            'Chief Petty Officer',
            'Warrant Officer 2',
            'Warrant Officer 1',
          ],
        };
      case 'France':
        return {
          'ranks': [
            'Matelot',
            'Quartier-Maître',
            'Second-Maître',
            'Maître',
            'Premier Maître',
            'Maître Principal',
            'Major',
          ],
        };
      case 'Canada':
        return {
          'ranks': [
            'Ordinary Seaman',
            'Able Seaman',
            'Leading Seaman',
            'Master Seaman',
            'Petty Officer 2nd Class',
            'Petty Officer 1st Class',
            'Chief Petty Officer 2nd Class',
            'Chief Petty Officer 1st Class',
          ],
        };
      case 'Sweden':
        return {
          'ranks': [
            'Sjöman',
            'Roddare',
            'Marinkonstapel',
            'Båtsman',
            'Förste Båtsman',
            'Överbåtsman',
            'Marinförman',
          ],
        };
      case 'Brazil':
        return {
          'ranks': [
            'Marinheiro-Recruta',
            'Grumete',
            'Marinheiro',
            'Cabo',
            'Terceiro-Sargento',
            'Segundo-Sargento',
            'Primeiro-Sargento',
            'Suboficial',
          ],
        };
      case 'New Zealand':
        return {
          'ranks': [
            'Ordinary Rating',
            'Able Rating',
            'Leading Hand',
            'Petty Officer',
            'Chief Petty Officer',
            'Warrant Officer',
          ],
        };
      case 'Panama':
        return {
          'ranks': [
            'Marinero',
            'Cabo',
            'Sargento Segundo',
            'Sargento Primero',
            'Suboficial',
          ],
        };
      default:
        return {
          'ranks': [
            'Seaman Recruit (E-1)',
            'Petty Officer 3rd Class (E-4)',
            'Petty Officer 2nd Class (E-5)',
          ],
        };
    }
  }

  // Get Navy officer ranks
  static Map<String, List<String>> getNavyOfficerRanks(String nationality) {
    switch (nationality) {
      case 'USA':
        return {
          'ranks': [
            'Ensign (O-1)',
            'Lieutenant Junior Grade (O-2)',
            'Lieutenant (O-3)',
            'Lieutenant Commander (O-4)',
            'Commander (O-5)',
            'Captain (O-6)',
          ],
        };
      case 'United Kingdom':
        return {
          'ranks': [
            'Sub-Lieutenant',
            'Lieutenant',
            'Lieutenant Commander',
            'Commander',
            'Captain',
          ],
        };
      case 'France':
        return {
          'ranks': [
            'Enseigne de vaisseau 2e classe',
            'Enseigne de vaisseau 1re classe',
            'Lieutenant de vaisseau',
            'Capitaine de corvette',
            'Capitaine de frégate',
            'Capitaine de vaisseau',
          ],
        };
      case 'Canada':
        return {
          'ranks': [
            'Acting Sub-Lieutenant',
            'Sub-Lieutenant',
            'Lieutenant',
            'Lieutenant Commander',
            'Commander',
            'Captain',
          ],
        };
      case 'Sweden':
        return {
          'ranks': [
            'Fänrik',
            'Löjtnant',
            'Kapten',
            'Kommendörkapten',
            'Kommendör',
            'Överste',
          ],
        };
      case 'Brazil':
        return {
          'ranks': [
            'Guarda-Marinha',
            'Segundo-Tenente',
            'Primeiro-Tenente',
            'Capitão-Tenente',
            'Capitão de Corveta',
            'Capitão de Fragata',
            'Capitão de Mar e Guerra',
          ],
        };
      case 'New Zealand':
        return {
          'ranks': [
            'Ensign',
            'Sub-Lieutenant',
            'Lieutenant',
            'Lieutenant Commander',
            'Commander',
            'Captain',
          ],
        };
      case 'Panama':
        return {
          'ranks': [
            'Subteniente',
            'Teniente',
            'Capitán',
            'Mayor',
            'Teniente Coronel',
            'Coronel',
          ],
        };
      default:
        return {
          'ranks': [
            'Ensign (O-1)',
            'Lieutenant (O-3)',
            'Lieutenant Commander (O-4)',
          ],
        };
    }
  }

  // Get initial Navy enlisted ranks for character creation
  static Map<String, List<String>> getInitialNavyEnlistedRanks(
    String nationality,
  ) {
    switch (nationality) {
      case 'USA':
        return {
          'ranks': [
            'Seaman Recruit (E-1)',
            'Seaman Apprentice (E-2)',
            'Seaman (E-3)',
            'Petty Officer 3rd Class (E-4)',
          ],
        };
      case 'United Kingdom':
        return {
          'ranks': ['Able Rate', 'Leading Rate'],
        };
      case 'France':
        return {
          'ranks': ['Matelot', 'Quartier-Maître'],
        };
      case 'Canada':
        return {
          'ranks': ['Ordinary Seaman', 'Able Seaman'],
        };
      case 'Sweden':
        return {
          'ranks': ['Sjöman', 'Roddare'],
        };
      case 'Brazil':
        return {
          'ranks': ['Marinheiro-Recruta', 'Grumete', 'Marinheiro'],
        };
      case 'New Zealand':
        return {
          'ranks': ['Ordinary Rating', 'Able Rating'],
        };
      case 'Panama':
        return {
          'ranks': ['Marinero', 'Cabo'],
        };
      default:
        return {
          'ranks': [
            'Seaman Recruit (E-1)',
            'Seaman Apprentice (E-2)',
            'Petty Officer 3rd Class (E-4)',
          ],
        };
    }
  }

  // Get initial Navy officer ranks for character creation
  static Map<String, List<String>> getInitialNavyOfficerRanks(
    String nationality,
  ) {
    switch (nationality) {
      case 'USA':
        return {
          'ranks': ['Ensign (O-1)', 'Lieutenant Junior Grade (O-2)'],
        };
      case 'United Kingdom':
        return {
          'ranks': ['Sub-Lieutenant', 'Lieutenant'],
        };
      case 'France':
        return {
          'ranks': [
            'Enseigne de vaisseau 2e classe',
            'Enseigne de vaisseau 1re classe',
          ],
        };
      case 'Canada':
        return {
          'ranks': ['Acting Sub-Lieutenant', 'Sub-Lieutenant'],
        };
      case 'Sweden':
        return {
          'ranks': ['Fänrik', 'Löjtnant'],
        };
      case 'Brazil':
        return {
          'ranks': ['Guarda-Marinha', 'Segundo-Tenente'],
        };
      case 'New Zealand':
        return {
          'ranks': ['Ensign', 'Sub-Lieutenant'],
        };
      case 'Panama':
        return {
          'ranks': ['Subteniente', 'Teniente'],
        };
      default:
        return {
          'ranks': ['Ensign (O-1)', 'Lieutenant Junior Grade (O-2)'],
        };
    }
  }

  static List<String> getWeaponsLocker(String nationality) {
    switch (nationality) {
      case 'USA':
        return [
          'M16A4 Rifle',
          'M16A4 Rifle with M203 GL',
          'M4 Carbine',
          'M4 Carbine with M203 GL',
          'M249 SAW Light Machinegun',
          'M40 Sniper Rifle',
          'M24 Sniper Rifle',
          'M2010 ESR Sniper Rifle',
          'M13 Sniper Rifle',
          'M110 SASS Sniper Rifle',
          'Barrett M82 Sniper Rifle',
          'M240 Machine Gun',
          'M32 Grenade Launcher (GL)',
          'M9 Pistol',
          '1911 Pistol',
          'Glock 17 Pistol',
        ];
      case 'United Kingdom':
        return [
          'L85A2 Rifle',
          'L85A2 Rifle with GL',
          'FN Minimi Light Machinegun',
          'L115A3 Sniper Rifle',
          'Barrett M82 Sniper Rifle',
          'L7A2 Machine Gun',
          '2 inch mortar',
          'Browning HP Pistol',
        ];
      case 'France':
        return [
          'FAMAS rifle',
          'FAMAS rifle with GL',
          'HK416F with HK269F 40mm GL',
          'FN Minimi Light Machinegun',
          'FRF2 Sniper Rifle',
          'PGM Hecate II Sniper Rifle',
          'SCAR-H PR Sniper Rifle',
          'FN MAG 58 Machine Gun',
          'M9 Pistol',
          'PAMAS G1 Pistol',
        ];
      case 'Australian':
        return [
          'F88 Steyr Rifle',
          'F88 Steyr Rifle with GL',
          'FN Minimi Light Machinegun',
          'Barrett M82 Sniper Rifle',
          'SR-98 Sniper Rifle',
          'FN MAG 58 Machinegun',
          'Browning HP Pistol',
        ];
      case 'Canada':
        return [
          'C7A2',
          'C7A2 with GL',
          'FN Minimi Light Machinegun',
          'McMillan TAC-50 (C15) Sniper Rifle',
          'C14 Timberwolf MRSWS Sniper Rifle',
          'FN MAG 58 Machinegun',
          'M9 Pistol',
        ];
      case 'German':
        return [
          'HKG36E',
          'HKG36E with GL',
          'G22A2 Sniper rifle',
          'Barrett M82 Sniper Rifle',
          'Rheinmetall MG3',
          'M9 Pistol',
        ];
      case 'Spain':
        return [
          'HKG36E',
          'HKG36E with GL',
          'FN Minimi Light Machinegun',
          'Accuracy International AW308 Sniper',
          'Barrett M82 Sniper Rifle',
          'Rheinmetall MG3',
          'M9 Pistol',
        ];
      case 'Dutch':
        return [
          'C7A2',
          'C7A2 with GL',
          'FN Minimi Light Machinegun',
          'Accuracy International AW308 Sniper',
          'Barrett M82 Sniper Rifle',
          'FN MAG 58',
          'M9 Pistol',
        ];
      case 'Norway':
        return [
          'HK416',
          'HK416 with GL',
          'FN Minimi Light Machinegun',
          'L115A3 Sniper Rifle',
          'Barrett M82 Sniper Rifle',
          'Rheinmetall MG3',
          'M9 Pistol',
        ];
      case 'Polish':
        return [
          'Wz 96 Beryl',
          'Wz 96 Beryl with GL',
          'FN Minimi Light Machinegun',
          'TRG-42 Sniper Rifle',
          'SVD Dragonov Sniper Rifle',
          'PKM machinegun',
          'M9 Pistol',
        ];
      case 'Sweden':
        return [
          'AK5C Rifle',
          'FN Minimi (KSP 90)',
          'FN MAG GPMG',
          'AS90 Sniper Rifle',
          'AT-4',
          'Glock 17',
        ];
      case 'Brazil':
        return [
          'IMBEL IA2 Rifle (5.56mm)',
          'IMBEL IA2 Rifle with M203 GL',
          'FN FAL Rifle (7.62mm)',
          'FN FAL Rifle with GL',
          'FN Minimi SAW',
          'FN MAG GPMG',
          'PSG-1 Sniper Rifle',
          'Barrett M82 Sniper Rifle',
          'Taurus PT92 Pistol',
          'Taurus PT100 Pistol',
        ];
      case 'New Zealand':
        return [
          'Steyr AUG A1 Rifle',
          'Steyr AUG A1 with M203 GL',
          'IW Steyr Rifle',
          'FN Minimi SAW',
          'FN MAG 58 GPMG',
          'SR-98 Sniper Rifle',
          'Barrett M82 Sniper Rifle',
          'Browning HP Pistol',
          'Glock 17 Pistol',
        ];
      case 'Panama':
        return [
          'M16A2 Rifle',
          'M16A2 Rifle with M203 GL',
          'M4 Carbine',
          'M4 Carbine with M203 GL',
          'Galil ACE Rifle',
          'FN Minimi SAW',
          'M240 Machinegun',
          'Remington 700 Sniper Rifle',
          'Beretta 92 Pistol',
          'Glock 19 Pistol',
        ];
      case 'The Philippines':
        return [
          'M16A1 Rifle',
          'M16A1 Rifle with M203 GL',
          'M4 Carbine',
          'M4 Carbine with M203 GL',
          'HK416 Rifle',
          'DSAR-15 Rifle',
          'FN Minimi Light Machinegun',
          'FN MAG 58 Machinegun',
          'Rheinmetall MG3',
          'M9 Pistol',
          '1911 Pistol',
        ];
      default:
        return ['Standard Issue Rifle', 'Pistol'];
    }
  }

  /// Get rifles by nationality (for Rifleman, Radio Operator, Medical, Civil Affairs, JTAC, EOD)
  static List<String> getRifles(String nationality) {
    final allWeapons = getWeaponsLocker(nationality);
    return allWeapons.where((w) => 
      (w.contains('Rifle') || w.contains('rifle') || w.contains('Carbine')) && 
      !w.contains('Sniper') && 
      !w.contains('Light Machinegun') && 
      !w.contains('Machine Gun') &&
      !w.contains('Machinegun')
    ).toList();
  }

  /// Get sniper rifles by nationality
  static List<String> getSniperRifles(String nationality) {
    final allWeapons = getWeaponsLocker(nationality);
    return allWeapons.where((w) => w.contains('Sniper')).toList();
  }

  /// Get machine guns by nationality (for Heavy Weapons - GPMG)
  static List<String> getMachineGuns(String nationality) {
    final allWeapons = getWeaponsLocker(nationality);
    return allWeapons.where((w) => 
      w.contains('Machine Gun') || 
      w.contains('Machinegun') ||
      w.contains('GPMG') ||
      w.contains('MG3') ||
      w.contains('MAG') ||
      w.contains('PKM') ||
      w.contains('M240') ||
      w.contains('L7A2')
    ).toList();
  }

  /// Get light machine guns by nationality (SAW/Minimi for Rifleman)
  static List<String> getLightMachineGuns(String nationality) {
    final allWeapons = getWeaponsLocker(nationality);
    return allWeapons.where((w) => 
      w.contains('SAW') || 
      w.contains('Minimi') ||
      w.contains('KSP 90')
    ).toList();
  }

  /// Get pistols by nationality
  static List<String> getPistols(String nationality) {
    final allWeapons = getWeaponsLocker(nationality);
    return allWeapons.where((w) => w.contains('Pistol')).toList();
  }

  /// Get grenade launchers by nationality
  static List<String> getGrenadeLaunchers(String nationality) {
    final allWeapons = getWeaponsLocker(nationality);
    return allWeapons.where((w) => 
      w.contains('GL') || 
      w.contains('Grenade Launcher') ||
      w.contains('M32') ||
      w.contains('M203')
    ).toList();
  }

  /// Get names by nationality (last names / surnames)
  static List<String> getNames(String nationality) {
    switch (nationality) {
      case 'USA':
        return [
          'Jackson', 'Smith', 'Johnson', 'Williams', 'Brown', 'Davis', 'Miller',
          'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas', 'Martinez', 'Garcia',
          'Rodriguez', 'Lee', 'Walker', 'Hall', 'Allen', 'Young', 'King', 'Wright',
          'Lopez', 'Hill', 'Scott', 'Green', 'Adams', 'Baker', 'Nelson', 'Carter',
          'Mitchell', 'Roberts', 'Turner', 'Phillips', 'Campbell', 'Parker', 'Evans',
        ];
      case 'United Kingdom':
        return [
          'Smith', 'Jones', 'Williams', 'Brown', 'Taylor', 'Davies', 'Wilson',
          'Evans', 'Thomas', 'Roberts', 'Johnson', 'Lewis', 'Walker', 'Robinson',
          'Wood', 'Thompson', 'White', 'Watson', 'Jackson', 'Wright', 'Green',
          'Harris', 'Cooper', 'King', 'Lee', 'Martin', 'Clarke', 'James', 'Morgan',
          'Hughes', 'Edwards', 'Hill', 'Moore', 'Clark', 'Harrison', 'Scott',
        ];
      case 'France':
        return [
          'Martin', 'Bernard', 'Dubois', 'Thomas', 'Robert', 'Richard', 'Petit',
          'Durand', 'Leroy', 'Moreau', 'Simon', 'Laurent', 'Lefebvre', 'Michel',
          'Garcia', 'David', 'Bertrand', 'Roux', 'Vincent', 'Fournier', 'Morel',
          'Girard', 'Andre', 'Lefevre', 'Mercier', 'Dupont', 'Lambert', 'Bonnet',
          'Francois', 'Martinez', 'Legrand', 'Garnier', 'Faure', 'Rousseau', 'Blanc',
        ];
      case 'Canada':
        return [
          'Smith', 'Brown', 'Tremblay', 'Martin', 'Roy', 'Wilson', 'Gagnon',
          'Johnson', 'Taylor', 'MacDonald', 'Anderson', 'Lee', 'Williams', 'Jones',
          'White', 'Thompson', 'Scott', 'Campbell', 'Clark', 'Leblanc', 'Bouchard',
          'Gauthier', 'Morin', 'Lavoie', 'Fortin', 'Gagne', 'Ouellet', 'Cote',
          'Pelletier', 'Belanger', 'Page', 'Bergeron', 'Levesque', 'Bourque', 'Arsenault',
        ];
      case 'Norway':
        return [
          'Hansen', 'Johansen', 'Olsen', 'Larsen', 'Andersen', 'Pedersen', 'Nilsen',
          'Kristiansen', 'Jensen', 'Karlsen', 'Johnsen', 'Pettersen', 'Eriksen', 'Berg',
          'Haugen', 'Hagen', 'Johannessen', 'Andreassen', 'Jacobsen', 'Dahl', 'Jorgensen',
          'Halvorsen', 'Henriksen', 'Lund', 'Solberg', 'Moen', 'Nguyen', 'Svendsen',
          'Iversen', 'Bakken', 'Rasmussen', 'Strand', 'Eide', 'Knudsen', 'Martinsen',
        ];
      case 'Dutch':
        return [
          'De Jong', 'Jansen', 'De Vries', 'Van Den Berg', 'Van Dijk', 'Bakker',
          'Janssen', 'Visser', 'Smit', 'Meijer', 'De Boer', 'Mulder', 'De Groot',
          'Bos', 'Vos', 'Peters', 'Hendriks', 'Van Leeuwen', 'Dekker', 'Brouwer',
          'De Wit', 'Dijkstra', 'Smits', 'De Graaf', 'Van Der Meer', 'Van Der Linden',
          'Kok', 'Jacobs', 'De Haan', 'Vermeulen', 'Van Den Heuvel', 'Van Der Veen',
          'Van Den Broek', 'De Lange', 'Van Rijn', 'Van Wijk',
        ];
      case 'Australian':
        return [
          'Smith', 'Jones', 'Williams', 'Brown', 'Wilson', 'Taylor', 'Anderson',
          'Johnson', 'White', 'Martin', 'Thompson', 'Nguyen', 'Thomas', 'Walker',
          'Harris', 'Lee', 'Ryan', 'Robinson', 'Kelly', 'King', 'Campbell', 'Baker',
          'Clarke', 'Young', 'Allen', 'Scott', 'Green', 'Adams', 'Nelson', 'Mitchell',
          'Roberts', 'Turner', 'Phillips', 'Edwards', 'Murphy', 'Cook',
        ];
      case 'German':
        return [
          'Müller', 'Schmidt', 'Schneider', 'Fischer', 'Weber', 'Meyer', 'Wagner',
          'Becker', 'Schulz', 'Hoffmann', 'Schäfer', 'Koch', 'Bauer', 'Richter',
          'Klein', 'Wolf', 'Schröder', 'Neumann', 'Schwarz', 'Zimmermann', 'Braun',
          'Krüger', 'Hofmann', 'Hartmann', 'Lange', 'Schmitt', 'Werner', 'Schmitz',
          'Krause', 'Meier', 'Lehmann', 'Huber', 'Mayer', 'Herrmann', 'Walter', 'König',
        ];
      case 'Spain':
        return [
          'García', 'Rodríguez', 'González', 'Fernández', 'López', 'Martínez', 'Sánchez',
          'Pérez', 'Gómez', 'Martín', 'Jiménez', 'Ruiz', 'Hernández', 'Díaz', 'Moreno',
          'Álvarez', 'Muñoz', 'Romero', 'Alonso', 'Gutiérrez', 'Navarro', 'Torres',
          'Domínguez', 'Vázquez', 'Ramos', 'Gil', 'Ramírez', 'Serrano', 'Blanco', 'Suárez',
          'Molina', 'Castro', 'Ortega', 'Rubio', 'Morales', 'Delgado',
        ];
      case 'The Philippines':
        return [
          'Santos', 'Reyes', 'Cruz', 'Bautista', 'Garcia', 'Gonzales', 'Ramos',
          'Flores', 'Mendoza', 'Rivera', 'Castro', 'Del Rosario', 'Fernandez', 'Lopez',
          'Torres', 'Aquino', 'Villanueva', 'Diaz', 'Martinez', 'Rodriguez', 'Perez',
          'De Leon', 'Soriano', 'Santiago', 'Domingo', 'Romero', 'Lim', 'Tan', 'Go',
          'Silva', 'Aguilar', 'Castillo', 'Hernandez', 'Valdez', 'Mercado', 'Pascual',
        ];
      case 'Polish':
        return [
          'Nowak', 'Kowalski', 'Wiśniewski', 'Wójcik', 'Kowalczyk', 'Kamiński', 'Lewandowski',
          'Zieliński', 'Szymański', 'Woźniak', 'Dąbrowski', 'Kozłowski', 'Jankowski', 'Mazur',
          'Kwiatkowski', 'Krawczyk', 'Kaczmarek', 'Piotrowski', 'Grabowski', 'Pawłowski',
          'Michalski', 'Król', 'Wieczorek', 'Jabłoński', 'Wróbel', 'Nowakowski', 'Majewski',
          'Olszewski', 'Stępień', 'Malinowski', 'Jaworski', 'Adamczyk', 'Dudek', 'Nowicki',
          'Pawlak', 'Górski',
        ];
      case 'Sweden':
        return [
          'Andersson', 'Johansson', 'Karlsson', 'Nilsson', 'Eriksson', 'Larsson', 'Olsson',
          'Persson', 'Svensson', 'Gustafsson', 'Pettersson', 'Jonsson', 'Jansson', 'Hansson',
          'Bengtsson', 'Jönsson', 'Lindberg', 'Jakobsson', 'Magnusson', 'Olofsson', 'Lindström',
          'Lindqvist', 'Lindgren', 'Berg', 'Axelsson', 'Bergström', 'Lundberg', 'Lind',
          'Lundgren', 'Lundqvist', 'Mattsson', 'Berglund', 'Fredriksson', 'Sandberg', 'Henriksson',
          'Forsberg',
        ];
      case 'Brazil':
        return [
          'Silva', 'Santos', 'Oliveira', 'Souza', 'Rodrigues', 'Ferreira', 'Alves',
          'Pereira', 'Lima', 'Gomes', 'Costa', 'Ribeiro', 'Martins', 'Carvalho', 'Araújo',
          'Melo', 'Barbosa', 'Rocha', 'Dias', 'Castro', 'Almeida', 'Nascimento', 'Correia',
          'Tupã', 'Yara', 'Iracema', 'Guarani', 'Tupi', 'Araripe', 'Caramuru', 'Jandira',
          'Moema', 'Potira', 'Tainá', 'Ubirajara',
        ];
      case 'New Zealand':
        return [
          'Smith', 'Jones', 'Williams', 'Brown', 'Wilson', 'Taylor', 'Anderson', 'Thomas',
          'Walker', 'White', 'Robinson', 'Thompson', 'Campbell', 'Martin', 'Johnson', 'Lee',
          'Te Kanawa', 'Parata', 'Tana', 'Te Rauparaha', 'Ngata', 'Wihongi', 'Te Kooti',
          'Pomare', 'Ngatai', 'Tamihana', 'Reweti', 'Aperahama', 'Henare', 'Wiremu',
          'Tipene', 'Hohepa', 'Piripi', 'Hemi', 'Rangi', 'Aroha',
        ];
      case 'Panama':
        return [
          'Gonzalez', 'Rodriguez', 'Martinez', 'Pérez', 'Lopez', 'Garcia', 'Hernandez',
          'Sanchez', 'Ramirez', 'Torres', 'Flores', 'Rivera', 'Gomez', 'Diaz', 'Cruz',
          'Morales', 'Reyes', 'Gutierrez', 'Ortiz', 'Chavez', 'Castillo', 'Jimenez',
          'Ngäbe', 'Buglé', 'Emberá', 'Wounaan', 'Kuna', 'Teribe', 'Bri Bri',
          'Changuena', 'Chicheme', 'Silipico', 'Santana', 'Miranda',
        ];
      default:
        return [
          'Jackson', 'Smith', 'Johnson', 'Williams', 'Brown', 'Davis', 'Miller',
          'Wilson', 'Moore', 'Taylor', 'Anderson', 'Thomas', 'Martinez', 'Garcia',
        ];
    }
  }

  /// Get character hooks for a given specialty
  static List<String> getSpecialtyHooks(String specialty) {
    switch (specialty.replaceAll('SOF ', '')) {
      case 'Rifleman':
        return [
          'Wants to prove they\'re more than a replaceable grunt.',
          'Swore to protect one squadmate after a previous mission went bad.',
          'Writes down everything in a notebook for a future they\'re not sure they\'ll see.',
          'Collects small objects from villages as reminders of why the war matters or doesn\'t.',
          'Keeps volunteering for point man despite knowing the risks.',
          'Hides fear behind jokes and bravado but cracks in private moments.',
          'Secretly studies manuals and tactics hoping to qualify for a promotion.',
          'Believes the only thing keeping them alive are practiced drills.',
          'Sees themselves as the squad\'s shield, will step into fire without hesitation.',
          'Has a bad temper when civilians mock or disrespect the patrol.',
        ];
      case 'Sniper':
        return [
          'Obsessed with hunting one specific high-value target rumored to be nearby.',
          'Maintains an emotional detachment from kills, but loses sleep afterward.',
          'Builds obsessive fieldcraft rituals: the same way of setting gear every time.',
          'Struggles with being separated from the squad, feeling like a ghost among them.',
          'Never fires unless absolutely sure; terrified of hitting civilians.',
          'Keeps detailed journals about wind patterns, terrain, and enemy behavior.',
          'Regards every mission as a chess match and wants the "perfect shot."',
          'Hopes to eventually become an instructor and teach others the craft.',
          'Respects rival enemy marksmen and wants to identify them.',
          'Has difficulty returning to normal conversation after days observing alone.',
        ];
      case 'Radio Operator':
        return [
          'Fears of losing comms more than enemy fire, silence is the real killer.',
          'Keeps old broken radio parts as good-luck charms.',
          'Carries recordings of intercepted enemy chatter, searching for patterns.',
          'Torn between reporting everything and protecting team privacy.',
          'Dreams of becoming a cyber-warfare specialist.',
          'Fixes radios under fire and takes pride in saving missions that way.',
          'Always tries to stay near the JTAC to learn from them.',
          'Feels responsible for calling for help in time when things go bad.',
          'Constantly gets stuck carrying extra batteries, even ones they don\'t need.',
          'Has a superstition that a clean radio means a bad mission.',
        ];
      case 'Heavy Weapons':
        return [
          'Loves the roar of a machine gun, it feels like control in chaos.',
          'Takes responsibility for the whole squad\'s fire superiority.',
          'Keeps weapons spotless and gets irritated when others don\'t.',
          'Dreams of joining a dedicated weapons company.',
          'Feels guilty when collateral damage occurs due to their volume of fire.',
          'Volunteers to carry extra ammunition even when exhausted.',
          'Loves the teamwork and choreography of setting up a heavy weapon.',
          'Risk-taker who wants to "see what\'s over that ridge."',
          'Faithfully follows the tripod placement doctrine like a religion.',
          'Wants to prove they can do more than just carry big guns.',
        ];
      case 'Signals Intel':
        return [
          'Knows everyone\'s secrets from intercepted chatter, and hates that burden.',
          'Loves solving digital puzzles and cracking hidden networks.',
          'Tries to track one specific enemy facilitator or paymaster.',
          'Uses slang and terminology nobody else understands.',
          'Worries constantly about being hacked in return.',
          'Keeps encrypted evidence files for future analysis.',
          'Treats hacking like a competitive sport.',
          'Feels guilty when intel fails to prevent an attack.',
          'Wants to transition into an intelligence agency after deployment.',
          'Always suspects there\'s another layer behind every clue.',
        ];
      case 'Civil Affairs':
        return [
          'Keeps photos of every project completed, schools, wells, clinics.',
          'Hates seeing kids afraid of soldiers and works to change it.',
          'Speaks multiple dialects and wants to master more.',
          'Carries candy or small gifts for children to build trust.',
          'Torn between helping civilians and following strict mission timelines.',
          'Has a personal bond with a local family or elder.',
          'Wants to shift from combat to full-time humanitarian missions.',
          'Distrusts kinetic operations and prefers negotiated solutions.',
          'Keeps detailed assessments of villages and tries to predict insurgent influence.',
          'Often gets accused of being "too nice", but results prove them right.',
        ];
      case 'Medical':
        return [
          'Keeps a list of everyone they\'ve saved, and everyone they haven\'t.',
          'Stores notes of medical treatments as if preparing for future paramedic school.',
          'Gets angry when soldiers don\'t hydrate or take care of themselves.',
          'Tries to comfort wounded enemies; believes life is life.',
          'Has a ritual before every patrol: re-check kit, re-check fate.',
          'Blames themselves for casualties even when they couldn\'t prevent them.',
          'Teaches locals basic first aid when allowed.',
          'Tries to remain calm at all times but breaks down in private.',
          'Feels protective of the entire platoon, like an older sibling.',
          'Collects patches or tags from friendly medics they meet along deployments.',
        ];
      case 'JTAC':
        return [
          'Thrives on the pressure of calling in close-air support within meters.',
          'Gets frustrated with slow air tasking or unclear comms.',
          'Treats aircraft like old friends and talks to pilots respectfully.',
          'Has nightmares about misdirected strikes.',
          'Sees terrain in terms of angles, lines, and danger zones.',
          'Wants to transition to aviation after service.',
          'Loves gadgets: lasers, tablets, radios, everything with buttons.',
          'Gets excited when pilots recognize their callsign.',
          'Feels guilty when aircraft can\'t respond due to weather or rules of engagement.',
          'Believes precision saves lives and follows procedure religiously.',
        ];
      case 'EOD':
        return [
          'Lost someone to an Improvised Explosive Device, now takes every device personally.',
          'Treats their detection dog as their closest partner.',
          'Loves the science behind explosives and sees each device as a puzzle.',
          'Gets visibly tense around fresh dirt, trash piles, or culverts.',
          'Has a dark sense of humor when defusing bombs.',
          'Still writes letters to the family of someone they couldn\'t save.',
          'Keeps fragments of safely detonated devices as trophies.',
          'Has an instinctive "sixth sense" for danger that unnerves others.',
          'Volunteers to clear dangerous lanes alone, everyone else is too precious.',
          'Dreams of joining a national bomb disposal unit after deployment.',
        ];
      case 'Agent':
        return [
          'Juggles two identities and fears one will collapse.',
          'Likes the squad genuinely but hides true mission orders.',
          'Has a handler who keeps changing instructions.',
          'Struggles with lying to people they trust.',
          'Learn local customs with uncanny ease.',
          'Collects small intel pieces and assembles bigger networks quietly.',
          'Can\'t shake the feeling their cover is already blown.',
          'Constantly evaluates teammates, who can be trusted, who cannot.',
          'Has a past mission that went catastrophically wrong.',
          'Wants out of the clandestine life but doesn\'t know how.',
        ];
      default:
        return [
          'Has a strong sense of duty and honor.',
          'Keeps mementos from each mission.',
          'Writes letters home regularly.',
          'Forms close bonds with squadmates.',
          'Always volunteers for tough assignments.',
          'Dreams of a peaceful life after service.',
          'Struggles with the weight of command decisions.',
          'Finds comfort in routine and discipline.',
          'Protects the team at all costs.',
          'Questions the purpose of the mission sometimes.',
        ];
    }
  }

  /// Auto-promote character to Corporal (E-4) if below Sergeant (E-5)
  /// Returns promoted rank or original rank if already E-5+
  static String autoPromoteToCorporal(
    String currentRank,
    String nationality,
    String service,
  ) {
    // Get the appropriate rank list
    final Map<String, List<String>> rankData;
    if (service == 'Navy') {
      rankData = getNavyEnlistedRanks(nationality);
    } else {
      rankData = getEnlistedRanks(nationality);
    }

    final ranks = rankData['ranks']!;
    final currentIndex = ranks.indexOf(currentRank);

    // If rank not found or already at E-5 (Sergeant equivalent), return current rank
    if (currentIndex == -1 || currentIndex >= 4) {
      return currentRank;
    }

    // Promote to E-4 (Corporal/Petty Officer 3rd Class equivalent)
    // E-4 is typically at index 3 (0-indexed: E-1, E-2, E-3, E-4)
    if (ranks.length > 3) {
      return ranks[3];
    }

    return currentRank;
  }

  /// Auto-promote to Sergeant (E-5) - required for EOD/JTAC specialties
  static String autoPromoteToSergeant(
    String currentRank,
    String nationality,
    String service,
  ) {
    // Get the appropriate rank list
    final Map<String, List<String>> rankData;
    if (service == 'Navy') {
      rankData = getNavyEnlistedRanks(nationality);
    } else {
      rankData = getEnlistedRanks(nationality);
    }

    final ranks = rankData['ranks']!;
    final currentIndex = ranks.indexOf(currentRank);

    // If rank not found or already at E-5 or higher, return current rank
    if (currentIndex == -1 || currentIndex >= 4) {
      return currentRank;
    }

    // Promote to E-5 (Sergeant/Petty Officer 2nd Class equivalent)
    // E-5 is typically at index 4 (0-indexed: E-1, E-2, E-3, E-4, E-5)
    if (ranks.length > 4) {
      return ranks[4];
    }

    return currentRank;
  }

  /// Check if a rank is below Sergeant (E-5) level
  static bool isBelowSergeant(String rank, String nationality, String service) {
    final Map<String, List<String>> rankData;
    if (service == 'Navy') {
      rankData = getNavyEnlistedRanks(nationality);
    } else {
      rankData = getEnlistedRanks(nationality);
    }

    final ranks = rankData['ranks']!;
    final currentIndex = ranks.indexOf(rank);

    // E-5 is typically at index 4 (0-indexed: E-1, E-2, E-3, E-4, E-5)
    return currentIndex != -1 && currentIndex < 4;
  }

  /// Get a random hook for a specialty (simulates 1D10 roll)
  static String getRandomHook(String specialty) {
    final hooks = getSpecialtyHooks(specialty);
    final random = DateTime.now().millisecondsSinceEpoch % 10;
    return hooks[random];
  }

  /// Get military schools by nationality
  /// Returns nationality-specific equivalents to US schools
  /// Structure: [Small Boats, Air Assault, Airborne, Breacher, Ranger]
  static List<String> getSchools(String nationality) {
    switch (nationality) {
      case 'USA':
        return [
          'Small Boats',
          'Air Assault',
          'Airborne',
          'Breacher (Explosives +2)',
          'Ranger (Knowledge +1)',
        ];
      case 'United Kingdom':
        return [
          'Special Boat Service Training',
          'Air Assault Course',
          'Parachute Regiment Training',
          'Combat Engineering Course (Explosives +2)',
          'Commando Course (Knowledge +1)',
        ];
      case 'France':
        return [
          'Commando Marine',
          'Air Assault Training',
          'Parachute Training (TAP)',
          'Sapeur de Combat (Explosives +2)',
          'Commandos Parachutistes (Knowledge +1)',
        ];
      case 'Canada':
        return [
          'Naval Boarding Party',
          'Air Assault',
          'Basic Parachutist',
          'Combat Engineer (Explosives +2)',
          'JTF2 Selection (Knowledge +1)',
        ];
      case 'Norway':
        return [
          'Coastal Ranger Training',
          'Air Assault',
          'Fallskjermjeger (Airborne)',
          'Combat Engineer (Explosives +2)',
          'FSK Selection (Knowledge +1)',
        ];
      case 'Dutch':
        return [
          'Maritime Special Operations',
          'Air Assault Brigade',
          'Parachute Training',
          'Combat Engineer (Explosives +2)',
          'Korps Commandotroepen (Knowledge +1)',
        ];
      case 'Australian':
        return [
          'Clearance Diving Team',
          'Air Assault Course',
          'Parachute Training',
          'Combat Engineer (Explosives +2)',
          'SASR Selection (Knowledge +1)',
        ];
      case 'German':
        return [
          'Kampfschwimmer Training',
          'Air Assault',
          'Fallschirmjäger',
          'Pioniertruppe (Explosives +2)',
          'KSK Selection (Knowledge +1)',
        ];
      case 'Spain':
        return [
          'Unidad de Operaciones Especiales',
          'Air Assault',
          'Parachute Training (BRIPAC)',
          'Zapadores (Explosives +2)',
          'MOE Selection (Knowledge +1)',
        ];
      case 'The Philippines':
        return [
          'Naval Special Operations',
          'Air Assault',
          'Airborne Training',
          'Combat Engineer (Explosives +2)',
          'Scout Ranger Course (Knowledge +1)',
        ];
      case 'Polish':
        return [
          'FORMOZA Training',
          'Air Assault',
          'Airborne Forces Training',
          'Saperzy (Explosives +2)',
          'GROM Selection (Knowledge +1)',
        ];
      case 'Sweden':
        return [
          'Kustjägarna Training',
          'Air Assault',
          'Fallskärmsjägare',
          'Combat Engineer (Explosives +2)',
          'SSG Selection (Knowledge +1)',
        ];
      case 'Brazil':
        return [
          'GRUMEC Training',
          'Air Assault (Brigada de Infantaria Paraquedista)',
          'Parachute Training',
          'Combat Engineer (Explosives +2)',
          'CIGS Jungle Warfare (Knowledge +1)',
        ];
      case 'New Zealand':
        return [
          'Maritime Counter Terrorism',
          'Air Assault Course',
          'Parachute Training',
          'Combat Engineer (Explosives +2)',
          'NZSAS Selection (Knowledge +1)',
        ];
      case 'Panama':
        return [
          'Maritime Operations',
          'Air Assault',
          'Jungle Warfare',
          'Explosives Handling (Explosives +2)',
          'UN Peacekeeping Course (Knowledge +1)',
        ];
      default:
        return [
          'Small Boats',
          'Air Assault',
          'Airborne',
          'Breacher (Explosives +2)',
          'Ranger (Knowledge +1)',
        ];
    }
  }

  /// Get SOF schools by nationality
  /// Returns nationality-specific advanced schools for SOF members
  static List<String> getSOFSchools(String nationality) {
    switch (nationality) {
      case 'USA':
        return [
          'Small Boats / SCUBA',
          'Air Assault / Language',
          'Airborne / Master Airborne',
          'Underground / Jungle / Mountain Warfare',
          'Breacher (Explosives +2)',
          'Hostage Rescue (Small Arms +1)',
        ];
      case 'United Kingdom':
        return [
          'SBS Maritime Operations / Advanced Diving',
          'Air Mobile Operations / Language Training',
          'HALO/HAHO Advanced Airborne',
          'Close Target Recce / Mountain Leader',
          'Urban Assault Specialist (Explosives +2)',
          'CT/Hostage Rescue (Small Arms +1)',
        ];
      case 'France':
        return [
          'Nageur de Combat / Advanced Diving',
          'Heliport Assault / Language School',
          'HALO/HAHO Operations',
          'Mountain Warfare / Jungle Training',
          'Demolitions Expert (Explosives +2)',
          'GIGN Tactics (Small Arms +1)',
        ];
      case 'Canada':
        return [
          'Combat Diving / Naval Operations',
          'Helicopter Insertion / Languages',
          'Military Freefall Parachutist',
          'Arctic Warfare / Mountain Ops',
          'Breaching Specialist (Explosives +2)',
          'Close Protection / CQB (Small Arms +1)',
        ];
      case 'Norway':
        return [
          'Naval Combat Diver / Maritime Ops',
          'Helicopter Assault / Russian Language',
          'High Altitude Operations',
          'Winter Warfare / Mountain Leader',
          'Explosive Ordnance (Explosives +2)',
          'Counter-Terror Operations (Small Arms +1)',
        ];
      case 'Dutch':
        return [
          'Combat Diving Unit / Maritime',
          'Air Maneuver / Language Training',
          'Military Parachutist Advanced',
          'Extreme Environment Training',
          'Demolitions Course (Explosives +2)',
          'Close Quarters Battle (Small Arms +1)',
        ];
      case 'Australian':
        return [
          'Clearance Diving / Water Operations',
          'Rotary Wing Operations / Language',
          'Military Freefall',
          'Jungle Warfare / Regional Training',
          'Advanced Breaching (Explosives +2)',
          'Tactical Assault (Small Arms +1)',
        ];
      case 'German':
        return [
          'Kampfschwimmer Operations / Diving',
          'Heliborne Operations / Language',
          'High Altitude Low Opening',
          'Mountain Combat / Urban Ops',
          'Explosive Entry (Explosives +2)',
          'GSG9 Tactics (Small Arms +1)',
        ];
      case 'Spain':
        return [
          'Combat Diving / Naval Special Ops',
          'Helicopter Operations / Arabic',
          'Military Parachuting Advanced',
          'Mountain / Desert Warfare',
          'Breaching Techniques (Explosives +2)',
          'CQB / Hostage Rescue (Small Arms +1)',
        ];
      case 'The Philippines':
        return [
          'Naval Special Warfare / Diving',
          'Air Assault / Local Languages',
          'Airborne Operations Advanced',
          'Jungle Warfare / Island Operations',
          'Combat Engineering (Explosives +2)',
          'Close Quarters Combat (Small Arms +1)',
        ];
      case 'Polish':
        return [
          'FORMOZA Diving / Maritime Ops',
          'Air Assault / Eastern Languages',
          'Airborne Special Operations',
          'Mountain / Urban Warfare',
          'Demolitions Expert (Explosives +2)',
          'Tactical Intervention (Small Arms +1)',
        ];
      case 'Sweden':
        return [
          'Kustjägarna Diving / Maritime',
          'Helicopter Assault / Nordic Languages',
          'Military Freefall Operations',
          'Arctic / Mountain Warfare',
          'Advanced Breaching (Explosives +2)',
          'Counter-Terrorism (Small Arms +1)',
        ];
      case 'Brazil':
        return [
          'GRUMEC Diving / Maritime Special Ops',
          'Jungle Helicopter Operations / Indigenous Languages',
          'HALO/HAHO Advanced Parachuting',
          'Jungle Warfare / Riverine Operations',
          'Demolitions & EOD (Explosives +2)',
          'Urban Counter-Terrorism (Small Arms +1)',
        ];
      case 'New Zealand':
        return [
          'NZSAS Maritime / Combat Diving',
          'Helicopter Assault / Māori Language',
          'Military Freefall Operations',
          'Mountain Warfare / Pacific Operations',
          'Advanced Explosives (Explosives +2)',
          'Close Quarter Battle (Small Arms +1)',
        ];
      case 'Panama':
        return [
          'Maritime Law Enforcement / Diving',
          'Air Operations / Indigenous Languages',
          'Jungle Patrol Operations',
          'Riverine / Coastal Operations',
          'Explosives & Ordnance (Explosives +2)',
          'UN Peacekeeping Tactics (Small Arms +1)',
        ];
      default:
        return [
          'Small Boats / SCUBA',
          'Air Assault / Language',
          'Airborne / Master Airborne',
          'Underground / Jungle / Mountain Warfare',
          'Breacher (Explosives +2)',
          'Hostage Rescue (Small Arms +1)',
        ];
    }
  }

  /// Get deployment awards by nationality
  /// Returns a map with 'awards' (5-tier list) and 'wound' (wound decoration)
  static Map<String, dynamic> getDeploymentAwards(String nationality) {
    switch (nationality) {
      case 'USA':
        return {
          'awards': [
            'None',
            'Achievement Medal',
            'Commendation Medal (+1 Knowledge)',
            'Bronze Star (+2 Knowledge)',
            'Silver Star (+3 Knowledge)',
          ],
          'wound': 'Purple Heart',
        };
      case 'United Kingdom':
        return {
          'awards': [
            'None',
            'Mentioned in Dispatches',
            'Queen\'s Commendation for Bravery (+1 Knowledge)',
            'Military Cross (+2 Knowledge)',
            'Distinguished Service Order (+3 Knowledge)',
          ],
          'wound': 'Wound Stripe',
        };
      case 'France':
        return {
          'awards': [
            'None',
            'Citation à l\'ordre',
            'Croix de Guerre avec Étoile (+1 Knowledge)',
            'Médaille Militaire (+2 Knowledge)',
            'Légion d\'Honneur (+3 Knowledge)',
          ],
          'wound': 'Blessure de Guerre',
        };
      case 'Canada':
        return {
          'awards': [
            'None',
            'Mentioned in Dispatches',
            'Commander\'s Commendation (+1 Knowledge)',
            'Star of Military Valour (+2 Knowledge)',
            'Victoria Cross (+3 Knowledge)',
          ],
          'wound': 'Sacrifice Medal',
        };
      case 'Norway':
        return {
          'awards': [
            'None',
            'Mentioned in Dispatches',
            'King\'s Medal of Merit (+1 Knowledge)',
            'War Cross with Sword (+2 Knowledge)',
            'St. Olav\'s Medal with Oak Branch (+3 Knowledge)',
          ],
          'wound': 'Wound Medal',
        };
      case 'Dutch':
        return {
          'awards': [
            'None',
            'Mentioned in Dispatches',
            'Bronze Cross (+1 Knowledge)',
            'Military Order of William (Knight) (+2 Knowledge)',
            'Military Order of William (Officer) (+3 Knowledge)',
          ],
          'wound': 'Wound Badge',
        };
      case 'Australian':
        return {
          'awards': [
            'None',
            'Mentioned in Dispatches',
            'Commendation for Gallantry (+1 Knowledge)',
            'Medal for Gallantry (+2 Knowledge)',
            'Victoria Cross for Australia (+3 Knowledge)',
          ],
          'wound': 'Wound Badge',
        };
      case 'German':
        return {
          'awards': [
            'None',
            'Ehrenzeichen der Bundeswehr',
            'Ehrenkreuz in Bronze (+1 Knowledge)',
            'Ehrenkreuz in Silber (+2 Knowledge)',
            'Ehrenkreuz in Gold (+3 Knowledge)',
          ],
          'wound': 'Verwundetenabzeichen',
        };
      case 'Spain':
        return {
          'awards': [
            'None',
            'Cruz al Mérito Militar (White)',
            'Cruz al Mérito Militar con Distintivo Amarillo (+1 Knowledge)',
            'Medalla Militar Individual (+2 Knowledge)',
            'Cruz Laureada de San Fernando (+3 Knowledge)',
          ],
          'wound': 'Medalla de Sufrimientos por la Patria',
        };
      case 'The Philippines':
        return {
          'awards': [
            'None',
            'Military Merit Medal',
            'Distinguished Conduct Star (+1 Knowledge)',
            'Distinguished Service Star (+2 Knowledge)',
            'Medal of Valor (+3 Knowledge)',
          ],
          'wound': 'Wounded Personnel Medal',
        };
      case 'Polish':
        return {
          'awards': [
            'None',
            'Medal for Merit to National Defence',
            'Bronze Cross of Merit with Swords (+1 Knowledge)',
            'Silver Cross of Merit with Swords (+2 Knowledge)',
            'Cross of Valour (+3 Knowledge)',
          ],
          'wound': 'Medal for Wounds and Contusions',
        };
      case 'Sweden':
        return {
          'awards': [
            'None',
            'För tapperhet i fält (9th size)',
            'För tapperhet i fält (8th size) (+1 Knowledge)',
            'Litteris et Artibus (+2 Knowledge)',
            'Seraphim Order (+3 Knowledge)',
          ],
          'wound': 'Sårad i Strid',
        };
      case 'Brazil':
        return {
          'awards': [
            'None',
            'Menção Honrosa',
            'Medalha de Mérito Militar (+1 Knowledge)',
            'Medalha do Pacificador (+2 Knowledge)',
            'Ordem do Mérito Militar (+3 Knowledge)',
          ],
          'wound': 'Ferido em Combate',
        };
      case 'New Zealand':
        return {
          'awards': [
            'None',
            'Mention in Dispatches',
            'New Zealand Gallantry Decoration (+1 Knowledge)',
            'New Zealand Gallantry Star (+2 Knowledge)',
            'Victoria Cross for New Zealand (+3 Knowledge)',
          ],
          'wound': 'Wound Stripe',
        };
      case 'Panama':
        return {
          'awards': [
            'None',
            'Mención de Honor',
            'Medalla al Mérito Policial (+1 Knowledge)',
            'Medalla al Valor (+2 Knowledge)',
            'Orden de Vasco Núñez de Balboa (+3 Knowledge)',
          ],
          'wound': 'Herido en Servicio',
        };
      default:
        return {
          'awards': [
            'None',
            'Achievement Medal',
            'Commendation Medal (+1 Knowledge)',
            'Bronze Star (+2 Knowledge)',
            'Silver Star (+3 Knowledge)',
          ],
          'wound': 'Purple Heart',
        };
    }
  }

  /// Get deployment locations by nationality (2010-2016 era)
  static List<String> getDeploymentLocations(String nationality) {
    switch (nationality) {
      case 'USA':
        return [
          'Iraq',
          'Afghanistan',
          'Syria',
          'Yemen',
          'Somalia',
          'Philippines',
          'Niger',
          'Libya',
        ];
      case 'United Kingdom':
        return [
          'Afghanistan',
          'Iraq',
          'Cyprus',
          'Falkland Islands',
          'Kenya',
          'Brunei',
          'Germany',
          'Mali',
        ];
      case 'France':
        return [
          'Afghanistan',
          'Mali',
          'Chad',
          'Central African Republic',
          'Ivory Coast',
          'Lebanon',
          'Djibouti',
          'Sahel',
        ];
      case 'Canada':
        return [
          'Afghanistan',
          'Iraq',
          'Kuwait',
          'Latvia',
          'Ukraine',
          'Mali',
          'Haiti',
          'Egypt (Sinai)',
        ];
      case 'Norway':
        return [
          'Afghanistan',
          'Iraq',
          'Mali',
          'Lithuania',
          'Syria',
          'Lebanon',
          'South Sudan',
          'Kosovo',
        ];
      case 'Dutch':
        return [
          'Afghanistan',
          'Iraq',
          'Mali',
          'Chad',
          'Lithuania',
          'Caribbean (Curaçao)',
          'Kosovo',
          'Bosnia',
        ];
      case 'Australian':
        return [
          'Afghanistan',
          'Iraq',
          'East Timor',
          'Solomon Islands',
          'Middle East',
          'UAE',
          'Malaysia',
          'Singapore',
        ];
      case 'German':
        return [
          'Afghanistan',
          'Kosovo',
          'Mali',
          'Lebanon',
          'Turkey',
          'Lithuania',
          'Somalia (anti-piracy)',
          'Sudan',
        ];
      case 'Spain':
        return [
          'Afghanistan',
          'Lebanon',
          'Bosnia',
          'Iraq',
          'Mali',
          'Turkey',
          'Indian Ocean (anti-piracy)',
          'Kosovo',
        ];
      case 'The Philippines':
        return [
          'Mindanao (counter-insurgency)',
          'Marawi',
          'Sulu Archipelago',
          'Jolo',
          'Basilan',
          'Haiti (UN)',
          'Golan Heights (UN)',
          'Liberia (UN)',
        ];
      case 'Polish':
        return [
          'Afghanistan',
          'Iraq',
          'Kosovo',
          'Chad',
          'Lebanon',
          'Syria',
          'Latvia',
          'Lithuania',
        ];
      case 'Sweden':
        return [
          'Afghanistan',
          'Mali',
          'Kosovo',
          'Bosnia',
          'Libya',
          'Lebanon',
          'Democratic Republic of Congo',
          'Somalia (anti-piracy)',
        ];
      case 'Brazil':
        return [
          'Tri-Border Area (Argentina-Paraguay)',
          'Haiti (MINUSTAH)',
          'Lebanon (UNIFIL)',
          'Democratic Republic of Congo (MONUSCO)',
          'Amazon Border Operations',
          'Liberia (UNMIL)',
          'Cyprus (UNFICYP)',
          'Central African Republic',
        ];
      case 'New Zealand':
        return [
          'Afghanistan (Bamiyan Province)',
          'Afghanistan (Kabul)',
          'Iraq (Taji)',
          'Sinai (MFO)',
          'South Korea (DMZ)',
          'East Timor',
          'Solomon Islands',
          'South Sudan (UNMISS)',
        ];
      case 'Panama':
        return [
          'Haiti (MINUSTAH)',
          'Liberia (UNMIL)',
          'South Sudan (UNMISS)',
          'Democratic Republic of Congo (MONUSCO)',
          'Western Sahara (MINURSO)',
          'Ivory Coast (UNOCI)',
          'Darfur (UNAMID)',
          'Central African Republic (MINUSCA)',
        ];
      default:
        return [
          'Iraq',
          'Afghanistan',
          'Syria',
          'Yemen',
          'Somalia',
          'Philippines',
        ];
    }
  }

  /// Get available medals by nationality
  static List<String> getMedals(String nationality) {
    switch (nationality) {
      case 'USA':
        return [
          'Medal of Honor',
          'Distinguished Service Cross',
          'Silver Star',
          'Bronze Star Medal',
          'Purple Heart',
          'Army Commendation Medal',
          'Army Achievement Medal',
          'Combat Infantryman Badge',
          'Combat Action Badge',
          'Meritorious Service Medal',
          'Good Conduct Medal',
          'National Defense Service Medal',
          'Afghanistan Campaign Medal',
          'Iraq Campaign Medal',
          'Global War on Terrorism Service Medal',
        ];
      case 'United Kingdom':
        return [
          'Victoria Cross',
          'Distinguished Service Order',
          'Military Cross',
          'Distinguished Conduct Medal',
          'Military Medal',
          'Mention in Despatches',
          'Queen\'s Gallantry Medal',
          'Conspicuous Gallantry Cross',
          'Operational Service Medal',
          'General Service Medal',
        ];
      case 'France':
        return [
          'Légion d\'honneur',
          'Médaille militaire',
          'Croix de guerre',
          'Croix de la Valeur militaire',
          'Médaille de la Défense nationale',
          'Médaille d\'outre-mer',
          'Médaille commémorative française',
        ];
      case 'Canada':
        return [
          'Victoria Cross',
          'Star of Military Valour',
          'Medal of Military Valour',
          'Meritorious Service Cross',
          'Canadian Forces\' Decoration',
          'General Campaign Star',
          'General Service Medal',
          'Special Service Medal',
        ];
      case 'Norway':
        return [
          'War Cross',
          'Defence Service Medal',
          'Medal for Heroic Deeds',
          'St. Olav\'s Medal',
          'King\'s Medal of Merit',
          'NATO Medal',
        ];
      case 'Dutch':
        return [
          'Military William Order',
          'Bronze Lion',
          'Cross of Merit',
          'Medal for Courage',
          'Expedition Medal',
          'NATO Medal',
        ];
      case 'Australian':
        return [
          'Victoria Cross for Australia',
          'Star of Gallantry',
          'Medal for Gallantry',
          'Commendation for Gallantry',
          'Distinguished Service Cross',
          'Australian Active Service Medal',
          'Australian Service Medal',
          'Infantry Combat Badge',
        ];
      case 'German':
        return [
          'Honour Cross of the Bundeswehr',
          'Badge of Honour of the Bundeswehr',
          'Cross of Honour for Valour',
          'Wound Badge',
          'NATO Medal',
          'ISAF Medal',
        ];
      case 'Spain':
        return [
          'Cruz Laureada de San Fernando',
          'Medalla Militar',
          'Cruz del Mérito Militar',
          'Cruz de Guerra',
          'Medalla de Sufrimientos por la Patria',
        ];
      case 'The Philippines':
        return [
          'Medal of Valor',
          'Distinguished Service Star',
          'Distinguished Conduct Star',
          'Military Merit Medal',
          'Gold Cross Medal',
          'Wounded Personnel Medal',
          'Philippine Liberation Medal',
        ];
      case 'Polish':
        return [
          'Order of the Cross of Grunwald',
          'Cross of Valour',
          'Medal for Merit to National Defence',
          'Afghanistan Medal',
          'Iraq Medal',
          'NATO Medal',
        ];
      case 'Sweden':
        return [
          'För tapperhet i fält',
          'Medaljen för tapperhet till sjöss',
          'Försvarsmaktens förtjänstmedalj',
          'Hemvärnets förtjänstmedalj',
          'Missionmedaljen',
          'NATO Medal',
        ];
      case 'Brazil':
        return [
          'Medalha do Pacificador',
          'Ordem do Mérito Militar',
          'Medalha de Mérito Tamandaré',
          'Medalha do Mérito Aeronáutico',
          'Medalha de Campanha',
          'Medalha de Serviços Relevantes',
        ];
      case 'New Zealand':
        return [
          'Victoria Cross for New Zealand',
          'New Zealand Gallantry Star',
          'New Zealand Gallantry Decoration',
          'New Zealand Distinguished Service Decoration',
          'Operational Service Medal',
          'New Zealand General Service Medal',
        ];
      case 'Panama':
        return [
          'Orden de Vasco Núñez de Balboa',
          'Medalla al Valor',
          'Medalla al Mérito Policial',
          'Medalla de Servicios Distinguidos',
          'Medalla de Operaciones de Paz',
          'Medalla de la Fuerza Pública',
        ];
      default:
        return [
          'Medal of Honor',
          'Distinguished Service Medal',
          'Silver Star',
          'Bronze Star',
          'Purple Heart',
          'Campaign Medal',
          'Service Medal',
          'Good Conduct Medal',
        ];
    }
  }

  /// Get English translation/description for non-English award names
  static String? getAwardTooltip(String awardName) {
    final tooltips = {
      // French
      'Citation à l\'ordre': 'Mentioned in Dispatches',
      'Croix de Guerre avec Étoile': 'War Cross with Star',
      'Médaille Militaire': 'Military Medal',
      'Légion d\'Honneur': 'Legion of Honor',
      'Blessure de Guerre': 'War Wound',

      // German
      'Ehrenzeichen der Bundeswehr': 'Badge of Honor of the Bundeswehr',
      'Ehrenkreuz in Bronze': 'Honor Cross in Bronze',
      'Ehrenkreuz in Silber': 'Honor Cross in Silver',
      'Ehrenkreuz in Gold': 'Honor Cross in Gold',
      'Verwundetenabzeichen': 'Wound Badge',

      // Spanish
      'Cruz al Mérito Militar (White)': 'Cross of Military Merit (White)',
      'Cruz al Mérito Militar con Distintivo Amarillo':
          'Cross of Military Merit with Yellow Distinction',
      'Medalla Militar Individual': 'Individual Military Medal',
      'Cruz Laureada de San Fernando': 'Laureate Cross of Saint Ferdinand',
      'Medalla de Sufrimientos por la Patria':
          'Medal of Suffering for the Homeland',

      // Swedish
      'För tapperhet i fält (9th size)': 'For Bravery in the Field (9th size)',
      'För tapperhet i fält (8th size)': 'For Bravery in the Field (8th size)',
      'Litteris et Artibus': 'For Learning and the Arts',
      'Seraphim Order': 'Order of the Seraphim',
      'Sårad i Strid': 'Wounded in Combat',

      // Brazilian
      'Menção Honrosa': 'Honorable Mention',
      'Medalha de Mérito Militar': 'Medal of Military Merit',
      'Medalha do Pacificador': 'Peacekeeper Medal',
      'Ordem do Mérito Militar': 'Order of Military Merit',
      'Ferido em Combate': 'Wounded in Combat',

      // New Zealand
      'Mention in Dispatches': 'Mentioned in Dispatches',
      'New Zealand Gallantry Decoration': 'Gallantry Decoration',
      'New Zealand Gallantry Star': 'Gallantry Star for bravery',
      'Victoria Cross for New Zealand': 'Highest military honor',
      'Wound Stripe': 'Wound Stripe',

      // Panama
      'Mención de Honor': 'Honorable Mention',
      'Medalla al Mérito Policial': 'Medal of Police Merit',
      'Medalla al Valor': 'Medal of Valor',
      'Orden de Vasco Núñez de Balboa': 'Order of Vasco Núñez de Balboa',
      'Herido en Servicio': 'Wounded in Service',

      // Polish
      'Medal for Merit to National Defence':
          'Medal for Merit to National Defence',
      'Bronze Cross of Merit with Swords':
          'Bronze Cross of Merit with Swords (combat)',
      'Silver Cross of Merit with Swords':
          'Silver Cross of Merit with Swords (combat)',
      'Cross of Valour': 'Cross of Valour (highest bravery medal)',
      'Medal for Wounds and Contusions': 'Medal for Wounds and Contusions',

      // Norwegian (some use Norwegian terms)
      'King\'s Medal of Merit': 'Kongens fortjenstmedalje',
      'War Cross with Sword': 'Krigskorset med sverd',
      'St. Olav\'s Medal with Oak Branch': 'St. Olavsmedaljen med ekegren',

      // Dutch
      'Bronze Cross': 'Bronzen Kruis (for exceptional bravery)',
      'Military Order of William (Knight)':
          'Militaire Willems-Orde (Knight class)',
      'Military Order of William (Officer)':
          'Militaire Willems-Orde (Officer class)',
    };

    // Remove bonus text from award name for lookup
    final cleanName = awardName.split('(').first.trim();
    return tooltips[cleanName];
  }

  /// Get English translation/description for non-English school names
  static String? getSchoolTooltip(String schoolName) {
    final tooltips = {
      // French
      'Commando Marine': 'French Naval Commando Training',
      'Parachute Training (TAP)': 'Troupes Aéroportées (Airborne Troops)',
      'Sapeur de Combat': 'Combat Engineer',
      'Commandos Parachutistes': 'Parachute Commandos (elite airborne)',
      'Nageur de Combat / Advanced Diving': 'Combat Diver / Advanced Diving',
      'Heliport Assault / Language School':
          'Helicopter Assault / Language School',
      'HALO/HAHO Operations': 'High Altitude parachute operations',
      'Mountain Warfare / Jungle Training':
          'Mountain Warfare / Jungle Training',
      'Demolitions Expert': 'Advanced Explosives Training',
      'GIGN Tactics': 'National Gendarmerie Intervention Group tactics',

      // German
      'Fallschirmjäger': 'Paratroopers (Airborne)',
      'Pioniertruppe': 'Pioneer Troops (Combat Engineers)',
      'KSK Selection': 'Kommando Spezialkräfte (Special Forces Command)',
      'Kampfschwimmer Training': 'Combat Swimmer Training',
      'Kampfschwimmer Operations / Diving': 'Combat Swimmer Ops / Diving',
      'Heliborne Operations / Language': 'Helicopter Operations / Language',
      'High Altitude Low Opening': 'HALO parachute operations',
      'Mountain Combat / Urban Ops': 'Mountain Combat / Urban Operations',
      'Explosive Entry': 'Breaching and Explosives',
      'GSG9 Tactics': 'Federal Police Special Unit tactics',

      // Spanish
      'Unidad de Operaciones Especiales': 'Special Operations Unit',
      'Parachute Training (BRIPAC)': 'Parachute Brigade training',
      'Zapadores': 'Sappers (Combat Engineers)',
      'MOE Selection': 'Mando de Operaciones Especiales (Special Ops)',
      'Combat Diving / Naval Special Ops': 'Combat Diving / Naval Special Ops',
      'Helicopter Operations / Arabic': 'Helicopter Ops / Arabic Language',
      'Military Parachuting Advanced': 'Advanced Parachute Operations',
      'Mountain / Desert Warfare': 'Mountain / Desert Warfare',
      'Breaching Techniques': 'Explosive Breaching',
      'CQB / Hostage Rescue': 'Close Quarters Battle / Hostage Rescue',

      // Norwegian
      'Coastal Ranger Training': 'Kystjegerkommandoen (Coastal Rangers)',
      'Fallskjermjeger (Airborne)': 'Parachute Rangers',
      'FSK Selection': 'Forsvarets Spesialkommando (Special Forces)',
      'Naval Combat Diver / Maritime Ops': 'Naval Combat Diver / Maritime',
      'Helicopter Assault / Russian Language': 'Helicopter Assault / Russian',
      'High Altitude Operations': 'HALO/HAHO parachute operations',
      'Winter Warfare / Mountain Leader': 'Winter / Mountain Warfare',
      'Explosive Ordnance': 'EOD and Demolitions',
      'Counter-Terror Operations': 'CT Operations',

      // Dutch
      'Maritime Special Operations': 'Maritime Special Operations',
      'Air Assault Brigade': 'Air Assault Brigade training',
      'Korps Commandotroepen': 'Commando Corps (elite infantry)',
      'Combat Diving Unit / Maritime': 'Combat Diving / Maritime Ops',
      'Air Maneuver / Language Training': 'Air Maneuver / Language',
      'Military Parachutist Advanced': 'Advanced Parachute Operations',
      'Extreme Environment Training': 'Extreme Environment Operations',
      'Demolitions Course': 'Explosives and Demolitions',
      'Close Quarters Battle': 'CQB Tactics',

      // Swedish
      'Kustjägarna Training': 'Coastal Rangers Training',
      'Fallskärmsjägare': 'Parachute Rangers',
      'SSG Selection': 'Särskilda Skyddsgruppen (Special Protection)',
      'Kustjägarna Diving / Maritime': 'Coastal Rangers Diving / Maritime',
      'Helicopter Assault / Nordic Languages':
          'Helicopter Assault / Nordic Languages',
      'Military Freefall Operations': 'Military Freefall Parachuting',
      'Arctic / Mountain Warfare': 'Arctic / Mountain Warfare',
      'Advanced Breaching': 'Advanced Explosives Breaching',
      'Counter-Terrorism': 'Counter-Terrorism Operations',

      // Brazilian
      'GRUMEC Training': 'Grupo de Mergulhadores de Combate (Combat Divers)',
      'Air Assault (Brigada de Infantaria Paraquedista)': 'Airborne Brigade',
      'CIGS Jungle Warfare': 'Centro de Instrução de Guerra na Selva',
      'GRUMEC Diving / Maritime Special Ops': 'Naval Special Forces Diving',
      'Jungle Helicopter Operations / Indigenous Languages': 'Jungle Helo Ops',
      'HALO/HAHO Advanced Parachuting': 'High Altitude Parachute Operations',
      'Jungle Warfare / Riverine Operations': 'Jungle / Riverine Warfare',
      'Demolitions & EOD': 'Explosives and EOD training',
      'Urban Counter-Terrorism': 'Urban CT Operations',

      // New Zealand
      'Maritime Counter Terrorism': 'Maritime CT Operations',
      'NZSAS Selection': 'New Zealand Special Air Service Selection',
      'NZSAS Maritime / Combat Diving': 'NZSAS Diving and Maritime Ops',
      'Helicopter Assault / Māori Language': 'Helicopter Assault / Māori',
      'Mountain Warfare / Pacific Operations': 'Mountain / Pacific Ops',
      'Advanced Explosives': 'Advanced Explosive Breaching',
      'Close Quarter Battle': 'CQB Tactics',

      // Panama
      'Maritime Operations': 'Maritime Operations Training',
      'Jungle Warfare': 'Jungle Warfare Training',
      'Explosives Handling': 'Explosives and Ordnance Handling',
      'UN Peacekeeping Course': 'United Nations Peacekeeping Training',
      'Maritime Law Enforcement / Diving': 'Maritime Law Enforcement',
      'Air Operations / Indigenous Languages': 'Air Ops / Indigenous Languages',
      'Jungle Patrol Operations': 'Jungle Patrol Training',
      'Riverine / Coastal Operations': 'Riverine and Coastal Ops',
      'Explosives & Ordnance': 'Explosives and Ordnance',
      'UN Peacekeeping Tactics': 'UN Peacekeeping Tactics',

      // Polish
      'FORMOZA Training': 'Naval Special Forces Training',
      'Airborne Forces Training': 'Parachute Forces Training',
      'Saperzy': 'Sappers (Combat Engineers)',
      'GROM Selection': 'Grupa Reagowania Operacyjno-Manewrowego (elite)',
      'FORMOZA Diving / Maritime Ops': 'Naval Special Forces Diving',
      'Air Assault / Eastern Languages': 'Air Assault / Eastern Languages',
      'Airborne Special Operations': 'Special Airborne Operations',
      'Mountain / Urban Warfare': 'Mountain / Urban Warfare',
      'Demolitions Expert (Polish)': 'Advanced Demolitions',
      'Tactical Intervention': 'Tactical Intervention Operations',
    };

    // Remove bonus text from school name for lookup
    final cleanName = schoolName.split('(').first.trim();
    return tooltips[cleanName];
  }

  /// Get weapon description for tooltip
  static String? getWeaponTooltip(String weaponName) {
    final descriptions = {
      // US weapons
      'M16A4 Rifle': 'Standard service rifle, 5.56mm NATO, burst/semi-auto',
      'M16A4 Rifle with M203 GL': 'M16A4 with 40mm underslung grenade launcher',
      'M4 Carbine': 'Compact carbine, 5.56mm NATO, full/semi-auto',
      'M4 Carbine with M203 GL': 'M4 with 40mm grenade launcher attachment',
      'M249 SAW Light Machinegun':
          'Squad Automatic Weapon, 5.56mm NATO belt-fed',
      'M40 Sniper Rifle':
          'Bolt-action sniper rifle, 7.62mm NATO, USMC standard',
      'M24 Sniper Rifle':
          'Bolt-action precision rifle, 7.62mm NATO, Army standard',
      'M2010 ESR Sniper Rifle':
          'Enhanced Sniper Rifle, .300 Win Mag, 1200m range',
      'M13 Sniper Rifle': 'Long-range precision rifle, .300 Win Mag',
      'M110 SASS Sniper Rifle': 'Semi-auto sniper system, 7.62mm NATO',
      'Barrett M82 Sniper Rifle': 'Anti-materiel rifle, .50 BMG, 1800m+ range',
      'M240 Machine Gun': 'General Purpose Machine Gun, 7.62mm NATO belt-fed',
      'M32 Grenade Launcher (GL)': 'Revolving 6-shot 40mm grenade launcher',
      'M9 Pistol': 'Beretta 92FS, 9mm NATO, standard US sidearm',
      '1911 Pistol': 'Classic Colt M1911, .45 ACP semi-auto pistol',
      'Glock 17 Pistol': 'Austrian polymer-frame pistol, 9mm NATO',

      // French weapons
      'FAMAS rifle': 'French bullpup assault rifle, 5.56mm NATO, 950 RPM',
      'FAMAS rifle with GL': 'FAMAS with 40mm grenade launcher attachment',
      'HK416F with HK269F 40mm GL':
          'Modern French service rifle with 40mm GL (adopted 2017)',
      'FN Minimi Light Machinegun':
          'Belgian light machine gun, 5.56mm NATO, 750-1000 RPM',
      'FRF2 Sniper Rifle':
          'French bolt-action sniper rifle, 7.62mm NATO, 800m range',
      'PGM Hecate II Sniper Rifle':
          'French anti-materiel rifle, .50 BMG, 1800m range',
      'SCAR-H PR Sniper Rifle':
          'FN SCAR-H Precision Rifle, 7.62mm NATO, Legion sniper weapon',
      'FN MAG 58 Machine Gun':
          'Belgian GPMG, 7.62mm NATO, 600-1000 RPM belt-fed',
      'PAMAS G1 Pistol':
          'French Beretta 92FS variant, 9mm NATO, standard French sidearm',

      // UK weapons
      'L85A2 Rifle': 'British bullpup assault rifle, 5.56mm NATO, SA80 family',
      'L85A2 Rifle with GL': 'L85A2 with underslung grenade launcher',
      'L115A3 Sniper Rifle':
          'British sniper rifle, .338 Lapua Magnum, 1100m+ range',
      'L7A2 Machine Gun': 'British GPMG (FN MAG variant), 7.62mm NATO',
      '2 inch mortar': 'Light infantry mortar, 51mm',
      'Browning HP Pistol':
          'Browning Hi-Power, 9mm NATO, classic service pistol',

      // Australian weapons
      'F88 Steyr Rifle': 'Australian Steyr AUG bullpup, 5.56mm NATO',
      'F88 Steyr Rifle with GL': 'F88 with grenade launcher attachment',
      'FN Minimi (KSP 90)': 'Swedish/Australian FN Minimi variant, 5.56mm NATO',
      'SR-98 Sniper Rifle': 'Australian sniper rifle, 7.62mm NATO',

      // Canadian weapons
      'C7A2': 'Canadian Diemaco C7A2 assault rifle, 5.56mm NATO',
      'C7A2 with GL': 'C7A2 with M203 40mm grenade launcher',
      'McMillan TAC-50 (C15) Sniper Rifle':
          'Canadian long-range sniper, .50 BMG, 2000m+ record',
      'C14 Timberwolf MRSWS Sniper Rifle':
          'Medium Range Sniper Weapon, .338 Lapua Magnum',

      // German weapons
      'HKG36E': 'Heckler & Koch G36E assault rifle, 5.56mm NATO',
      'HKG36E with GL': 'G36E with AG36 40mm grenade launcher',
      'G22A2 Sniper rifle': 'German precision rifle, .300 Win Mag',
      'Rheinmetall MG3': 'German GPMG, 7.62mm NATO, 1200 RPM high rate',

      // Norwegian weapons
      'HK416': 'Heckler & Koch 416 assault rifle, 5.56mm NATO, piston-driven',
      'HK416 with GL': 'HK416 with 40mm grenade launcher',
      'Barrett M82': 'Anti-materiel rifle, .50 BMG',

      // Dutch weapons
      'Diemaco C7': 'Dutch service rifle (Canadian design), 5.56mm NATO',
      'Diemaco C7 with GL': 'C7 with M203 40mm grenade launcher',
      'Accuracy International AWM-F Sniper Rifle':
          'Precision sniper rifle, .338 Lapua Magnum',
      'FN MAG': 'General purpose machine gun, 7.62mm NATO',

      // Spanish weapons
      'HK G36E': 'Heckler & Koch G36E, 5.56mm NATO',
      'HK G36E with GL': 'G36E with 40mm grenade launcher',
      'Accuracy International AW308 Sniper':
          'Precision sniper rifle, .308 Win (7.62mm NATO)',
      'Barrett M82A1': 'Anti-materiel rifle, .50 BMG',
      'MG3': 'General purpose machine gun, 7.62mm NATO',

      // Philippine weapons
      'M16A1 Rifle': 'Classic M16 rifle, 5.56mm NATO, Vietnam-era design',
      'M16A1 Rifle with M203 GL': 'M16A1 with 40mm grenade launcher',
      'HK416 Rifle': 'Heckler & Koch 416, 5.56mm NATO, modern piston rifle',
      'DSAR-15 Rifle': 'Philippine-made AR-15 variant, 5.56mm NATO',
      'FN MAG 58': 'Belgian GPMG, 7.62mm NATO, 600-1000 RPM',

      // Polish weapons
      'Wz 96 Beryl': 'Polish assault rifle (AK-74 based), 5.56mm NATO',
      'Wz 96 Beryl with GL': 'Beryl with 40mm grenade launcher',
      'TRG-42 Sniper Rifle':
          'Finnish Sako TRG, .338 Lapua Magnum precision rifle',
      'SVD Dragonov Sniper Rifle':
          'Soviet semi-auto sniper, 7.62x54mmR, 800m range',
      'PKM machinegun': 'Soviet/Russian GPMG, 7.62x54mmR belt-fed, 650 RPM',

      // Swedish weapons
      'AK5C Rifle': 'Swedish FN FNC variant, 5.56mm NATO, compact model',
      'FN MAG GPMG': 'General purpose machine gun, 7.62mm NATO',
      'AS90 Sniper Rifle': 'Swedish precision rifle, .338 Lapua Magnum',

      // Brazilian weapons
      'IMBEL IA2 Rifle (5.56mm)': 'Brazilian assault rifle, 5.56mm NATO, gas-operated',
      'IMBEL IA2 Rifle with M203 GL': 'IA2 with 40mm grenade launcher',
      'FN FAL Rifle (7.62mm)': 'Belgian battle rifle, 7.62mm NATO, Brazilian variant',
      'FN FAL Rifle with GL': 'FAL with grenade launcher attachment',
      'PSG-1 Sniper Rifle': 'German precision rifle, 7.62mm NATO semi-auto',
      'Taurus PT92 Pistol': 'Brazilian Beretta 92 variant, 9mm',
      'Taurus PT100 Pistol': 'Brazilian pistol, .40 S&W',

      // New Zealand weapons
      'Steyr AUG A1 Rifle': 'Austrian bullpup rifle, 5.56mm NATO',
      'Steyr AUG A1 with M203 GL': 'AUG with 40mm grenade launcher',
      'IW Steyr Rifle': 'Individual Weapon Steyr, 5.56mm NATO variant',
      'SR-98 Sniper Rifle': 'New Zealand sniper rifle, 7.62mm NATO',
      'Browning HP Pistol': 'Browning Hi-Power, 9mm NATO classic pistol',

      // Panamanian weapons
      'M16A2 Rifle': 'US service rifle, 5.56mm NATO, 3-round burst',
      'M16A2 Rifle with M203 GL': 'M16A2 with 40mm grenade launcher',
      'Galil ACE Rifle': 'Israeli assault rifle, 5.56mm NATO, modern variant',
      'M240 Machinegun': 'US GPMG, 7.62mm NATO belt-fed',
      'Remington 700 Sniper Rifle': 'Bolt-action precision rifle, various calibers',
      'Beretta 92 Pistol': '9mm NATO semi-auto pistol',
      'Glock 19 Pistol': 'Compact 9mm NATO polymer pistol',

      // Common weapons (shared)
      'FN Minimi': 'Belgian light machine gun, 5.56mm NATO, 750-1000 RPM',
    };

    return descriptions[weaponName];
  }
}
