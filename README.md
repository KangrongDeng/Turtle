# Turtle

### Turtle is an interactive environmental education game that brings ocean conservation to life.

Players guide a baby sea turtle through the ocean, clearing debris, rescuing marine animals, and searching for its mother. Through exploration, interaction, and dialogue, Turtle turns environmental issues into an experience that players can see, explore, and emotionally connect with.

<img width="778" height="558" alt="scene1" src="https://github.com/user-attachments/assets/f648ae49-d635-4c00-9562-ddd04567f793" />

## 🌊 About the Game

Turtle is designed for children, teenagers, environmental educators, and anyone interested in ocean conservation.

Players experience the ocean from the perspective of a baby sea turtle. Along the journey, they clear marine debris, rescue trapped animals, and interact with marine creatures through dialogue. Each interaction connects an environmental problem with a living character and its story.

The goal is simple: find the mother turtle and make it home.

By turning abstract environmental issues into interactive experiences, Turtle encourages players to understand, care about, and protect the ocean through play.

<img width="778" height="558" alt="scene2" src="https://github.com/user-attachments/assets/5f9fcf45-6edf-433c-9538-c1a26e3e10fb" />

## ♿ Accessibility

Accessibility was considered throughout the design of Turtle.

* High-contrast visual cues help players with color vision deficiencies identify important tasks.
* Simple interactions avoid complex gestures and make gameplay easier to understand.
* Text-based dialogue and prompts ensure that the story does not rely on audio alone.
* Clear task clues help players with different cognitive abilities understand what to do next.
* A simple and familiar story makes the experience accessible to younger players.

Turtle aims to make environmental education not only engaging, but also accessible to more players.

<img width="778" height="558" alt="scene3" src="https://github.com/user-attachments/assets/168173c5-8b47-407f-9eb6-918abcb9c27b" />

## 🤖 On-Device AI

Turtle integrates Apple Foundation Models to bring local AI into the game.

Instead of relying entirely on predefined dialogue scripts, NPCs can generate responses based on the player’s input and the current game context. This makes conversations feel more natural and gives players more freedom to interact with characters.

Because the AI runs locally on the device, Turtle can provide AI-powered interactions without requiring a traditional cloud-based dialogue service.

This approach makes NPC interactions more dynamic, while also increasing the interactivity and replayability of the game.

🛠️ Technology

SwiftUI

The main user interface is built with SwiftUI, providing a modern and responsive interface for menus, dialogue, prompts, and other UI elements.

SpriteKit

SpriteKit handles the core 2D game experience, including:

* Scene rendering
* Character interactions
* Object interactions
* Animations
* Game nodes and positioning

This combination allows SwiftUI to handle the interface while SpriteKit focuses on the real-time game world.

Foundation Models

Foundation Models provides on-device AI capabilities for dynamic NPC conversations.

Player Input
     ↓
Game Context
     ↓
Foundation Models
     ↓
Context-Aware NPC Response
     ↓
Player Interaction

AVFAudio

AVFAudio is used for background music and sound effects, providing audio feedback during exploration, problem-solving, and interactions.

🧩 Tech Stack

SwiftUI
   │
   ├── User Interface
   ├── Dialogue
   └── Game Prompts
        │
        ▼
SpriteKit
   │
   ├── Game Scenes
   ├── Rendering
   ├── Interaction
   └── Animation
        │
        ▼
Foundation Models
   │
   └── On-Device AI NPC Dialogue
AVFAudio
   │
   └── Music & Sound Effects

🎮 Core Experience

Explore → Discover → Interact → Solve → Learn → Return Home

Turtle combines gameplay, environmental education, accessibility, and on-device AI into one interactive experience.

🚀 Run the Project

You can open and run Turtle using Xcode or Swift Playgrounds.

Xcode / Swift Playgrounds
        ↓
Open Turtle
        ↓
Build & Run
        ↓
Explore the Ocean

💡 Vision

Turtle started with a simple question:

What if learning about environmental protection felt like playing a game rather than reading a textbook?

Instead of telling players that ocean pollution is a problem, Turtle lets them experience its consequences through the eyes of a baby sea turtle.

Play. Explore. Care. Protect.

⸻
