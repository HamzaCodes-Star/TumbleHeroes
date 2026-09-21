# Tumble Heroes: Party Royale - 3D Mobile Knockout Party Game (Godot 4)

A complete 3D obstacle knockout party game  built for Android and Desktop using Godot 4.

---

## 🎮 Complete Feature Set

1. **Main Menu & Skin Customizer:**
   - 3D Menu interface with **Play Solo/Party** button.
   - Interactive **Skin Color Customizer** (Orange, Sky Blue, Toxic Lime, Neon Pink, Gold).
2. **Signature Player Physics & Movement:**
   - Snappy responsive locomotion with fast ground acceleration.
   - Jump & **mid-air double-jump "Dive"** (flings character forward into a belly slide).
   - Dynamic stumble & ragdoll slide when hit by obstacles.
3. **AI Bot Competitors:**
   - 4 animated AI bots running the course alongside the player.
   - Randomized jumping, wandering paths, color skins, and physics knockback.
4. **Interactive Obstacle Course:**
   - **Counter-Rotating Spinners (`spinner.gd`):** Dual spinning bars that knock players off course.
   - **Swinging Pendulum Hammer (`pendulum.gd`):** Giant oscillating obstacle swinging across the track.
   - **Disappearing Trap Tiles (`trap_tile.gd`):** Stepped-on tiles shake, fall away, and respawn after 3 seconds.
   - **Bouncy Launch Pads (`bouncy_pad.gd`):** Propel runners into the air to dive over gaps.
5. **Game Flow & Live HUD:**
   - Animated countdown sequence ("3", "2", "1", "TUMBLE!").
   - Match timer and live qualification tracker (`QUALIFIED: 0 / 4`).
   - Catch-all kill plane below the track for checkpoint respawns.
   - Finish line qualification and End-of-Round results screen with "PLAY AGAIN".
6. **Mobile Touch Controls (Android Ready):**
   - Left-thumb virtual floating analog joystick.
   - Right-thumb large "JUMP / DIVE" button.
   - Fully compatible with touchscreen touch inputs and desktop mouse clicks.

---

## 🚀 Quick Launch

You can launch and play the game immediately on your Mac:

```bash
cd /Users/mapmac/studio-projects/customjarvis/stumble_guys
./launch_game.sh
```

*(Or open the **Godot** app from Applications, click **Import**, select `customjarvis/stumble_guys/project.godot`, and press **F5**).*

---

## 🕹️ Controls

* **Keyboard (Mac / PC):**
  - `W, A, S, D` or `Arrow Keys`: Run
  - `Space`: Jump (press in mid-air to **Dive**)
* **Touch (Android / Mobile):**
  - **Left Screen:** Virtual analog joystick
  - **Right Screen:** "JUMP / DIVE" touch button

---

## 📱 1-Click Android Export

1. Connect your Android phone via USB and enable **USB Debugging**.
2. Open the project in Godot.
3. Go to **Project -> Export...** (the Android preset `export_presets.cfg` is already configured).
4. Click the **Android One-Click Deploy** icon in the top-right toolbar.
5. Godot will automatically build the APK and launch it on your connected phone.
