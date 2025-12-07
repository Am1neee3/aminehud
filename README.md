# 🚘 AmineHud - Premium FiveM HUD

**AmineHud** is a modern, premium HUD designed for FiveM ESX servers. It features a sleek glassmorphism aesthetic, fully draggable UI elements, and a dedicated vehicle speedometer that operates independently from the status bars.

![Project Status](https://img.shields.io/badge/Status-Active-success)
![Framework](https://img.shields.io/badge/Framework-ESX-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

* **Modern Aesthetics:** Designed with rounded corners, blur effects, gradients, and glassmorphism.
* **Player Status:** Clean indicators for Health, Armor, Hunger, Thirst, and Stamina.
* **Vehicle HUD:** dedicated display for Speed (KMH/MPH), Fuel level, and Engine Health.
* **Drag & Drop:** Move the Status Bar and Speedometer independently to customize your screen layout.
* **Toggle System:** Easily hide or show the HUD with a single keybind.

## 🛠️ Installation

1.  **Download:** Download the latest release and extract the `aminehud` folder.
2.  **Install:** Drag the `aminehud` folder into your server's `resources` directory.
3.  **Configure:** Add the following line to your `server.cfg` file:

    ```cfg
    ensure aminehud
    ```

### 📦 Dependencies

Ensure you have the following resources started before AmineHud:
* `es_extended` (Required for player data)
* `esx_status` (Required for Hunger/Thirst updates)

> **Note:** This HUD uses **FontAwesome** for icons via CDN. Ensure your server and clients have internet access. Alternatively, you can replace the link in `index.html` with a local library.

## ⚙️ Configuration

You can customize keys and units in the `config.lua` file:

| Config Option | Default | Description |
| :--- | :--- | :--- |
| `Config.ToggleKey` | `'K'` | Keybind to toggle the HUD visibility. |
| `Config.EditModeKey` | `'J'` | Keybind to enter UI Edit Mode. |
| `Config.EditModeCommand` | `'hudsettings'` | Chat command to enter Edit Mode. |
| `Config.SpeedUnit` | `'kmh'` | Set to `'kmh'` or `'mph'`. |

## 🎮 Controls & Usage

* **Toggle HUD:** Press <kbd>K</kbd> to hide or show the interface.
* **Edit HUD:** Press <kbd>J</kbd> or type `/hudsettings` to enter Edit Mode.
* **Move Elements:** While in Edit Mode, click and drag the **Status Bar** or **Speedometer** to your desired position.
* **Save & Exit:** Press <kbd>ENTER</kbd> to save your layout and close Edit Mode.

---

### 🤝 Support & Contribution

If you encounter any issues or have feature requests, please open an issue in the repository. Pull requests are welcome!
