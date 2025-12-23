# **Backgammon 2**!

### Once a board game, now a *screen* game!

> This is my *second* attempt at creating [Backgammon](https://en.wikipedia.org/wiki/Backgammon) in [Processing](https://processing.org/).

![demo](demo.gif)

## **Features**!!

- **Auto Setup**: Piece positions reset to home/start states upon holding the center button.

- **Auto Save/Load**: Piece positions save after each manual move, and load on game reopen.

- **Physics Engine**: Upon rolls, dice bounce around the screen and collide against each other.

- **Particle System**: Custom particle effects occur during gameplay (i.e. piece movement, dice doubles).

- **"Winner Progress"**: Above each player's dice is a progress bar, representing the players' progression to their piece homes (as a ratio).

- **Eased Movement**: There is no movable object in the game that does so *without* applying an ease.

## **Android Build Instructions**!!! \(Using [APDE](https://github.com/Calsign/APDE)\)

> I created this game with the intent of its code being exported to an Android app using the APDE app. In my experience, the [Processing for Android](https://android.processing.org/) framework has always been inconsistent and buggy (and outdated), so I opted against using it.

0. **[Install APDE from the official repo](https://github.com/Calsign/APDE)**

1. Copy the inner `backgammon-2` folder into APDE's `Sketchbook` folder (typically `./Sketchbook`)

2. Delete the inner `sketch.properies` file, and rename `APDE_sketch.properties` to `sketch.properties`. **\[IMPORTANT\]**

3. Comment/uncomment the indicated lines in `Ab_Main.pde` and `Util.pde` **\[IMPORTANT x2\]**

4. Open `APDE`, open `Sketches/backgammon-2`, tap the export setting button (`<>`) and select `App`

5. Tap the run button (`▶`) to compile, then install when prompted

## **Extra**!!!!

The behavior/appearence of pretty much everything in the game can be adjusted in the `backgammon-2/Aa_Config.pde` file!

My favorite variable: `Settings.BOARD_PILLARS_PER_SECTION`; this alters the amount of "pillars" (triangles) from the typical 6 (this value also determines the maximum die face).

## **Future / Contributions**!!!!!

This project receives occasional updates (when I come up with new features), but for the most part it is complete. That said, **feel free to submit any PRs and/or fork!**
