// -- Saving --


void saveGame() {
  String filename = Settings.SAVING_FILENAME;
  
  //try {
    String[] mapsStrings = formatSaveStrings();
    saveStrings(filename, mapsStrings);
  //}
  
  //catch (Exception e) {
  //  println(e);
  //}
}

void loadGame() {
  String filename = Settings.SAVING_FILENAME;
  
  try {
    String[] mapsStrings = loadStrings(filename);
    parseLoadStrings(mapsStrings);
  }
  
  catch(Exception e) {
    saveGame();
  }
}

String[] formatSaveStrings() {
  int[][] maps_separate = board.generatePiecePoolMaps();
  
  int mapLength = maps_separate[0].length;
  String[] mapsStrings = new String[2 * mapLength];
  
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < mapLength; j++) {
      int indexAppend = i * mapLength;
      int mapsIndex = j + indexAppend;
      
      mapsStrings[mapsIndex] = str(maps_separate[i][j]);
    }
  }
  
  return mapsStrings;
}

void parseLoadStrings(String[] mapsStrings) {
  int mapLength = mapsStrings.length / 2;
  
  int[][] maps_separate = new int[2][mapLength];
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < mapLength; j++) {
      int indexAppend = i * mapLength;
      int mapsIndex = j + indexAppend;
      
      maps_separate[i][j] = int(mapsStrings[mapsIndex]);
    }
  }
  
  board.initializeBoardSetup(maps_separate[0], maps_separate[1]);
}
