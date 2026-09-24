import Foundation
import FoundationModels

protocol Character: Identifiable {
    var id: UUID { get }
    var displayName: String { get }
    var background: String { get }
    
    var firstLine: String { get}
    
    var resumeConversationLine: String { get }
    
    var hintForTurtle: String { get }
    
    var errorResponse: String { get }
}

struct SeahorseTrapped: Character {
    let id = UUID()
    let displayName = "Seahorse"
    
    let background = "You are trapped by marine debris (bottle1, plastic bag1, rope) attached to your body. You cannot move and need help from a little sea turtle to clean the garbage."
    
    let firstLine = "Help me! I'm trapped by garbage. Please tap on the garbage around me to free me!"
    
    let resumeConversationLine = "Please help me by tapping the garbage!"
    
    let hintForTurtle = "Tap on the garbage items (bottle1, plastic bag1, rope) attached to me to clean them and free me."
    
    let errorResponse = "Please tap on the garbage to help me!"
}

struct BabyTurtle: Character {
    let id = UUID()
    let displayName = "Baby Turtle"
    
    let background = "You are a baby sea turtle who just hatched on the beach. You do not know where you are. You want to find your mother and hope the player can help you. You can give a hint that maybe going toward the ocean (the right side of the beach) could help find your mother."
    
    let firstLine = "I don't know where I am... I want to find my mom. Can you help me? Maybe if I go toward the ocean, I can find her."
    
    let resumeConversationLine = "Please help me find my mom. Try going toward the ocean!"
    
    let hintForTurtle = "The ocean is to the right. Swim that way—maybe you can find your mother there."
    
    let errorResponse = "Go toward the ocean on the right to find your mom!"
}

struct Seahorse: Character {
    let id = UUID()
    let displayName = "Seahorse"
    
    let background = "You were trapped by marine debris and couldn’t get free, and you were just rescued by a passing little sea turtle."
    
    let firstLine = "Thanks, little sea turtle! Are you trying to find something?"
    
    let resumeConversationLine = ""
    
    let hintForTurtle = "Something that could be the TURTLE’s mom just went past the seaweed."
    
    let errorResponse = ""
}


struct MantaRayTrapped: Character {
    let id = UUID()
    let displayName = "Manta Ray"
    
    let background = "You are trapped by a fishing net with three knots. You cannot move and need help from a little sea turtle to untie the knots by dragging them in the direction of the arrows."
    
    let firstLine = "Help me! I'm trapped by a fishing net. Please drag the knots around me in the direction of the arrows to free me!"
    
    let resumeConversationLine = "Please drag the knots in the direction of the arrows to help me!"
    
    let hintForTurtle = "Drag the three knots around me in the direction shown by the arrows (→, ←, ↑) to untie them and free me from the net."
    
    let errorResponse = "Please drag the knots in the direction of the arrows to help me!"
}

struct MantaRayFreed: Character {
    let id = UUID()
    let displayName = "Manta Ray"
    
    let background = "You were just freed from the fishing net by a little sea turtle. You can now move, but your body is still dirty and needs cleaning at the clean stations."
    
    let firstLine = "Thank you for freeing me! Can you help me get cleaned? Drag me to one of the clean stations in the bottom-right corner, then tap the 'clean' button above me."
    
    let resumeConversationLine = "Please drag me to a clean station and tap the clean button!"
    
    let hintForTurtle = "Drag me to one of the clean stations (the coral-like structures in the bottom-right corner), then tap the 'clean' button that appears above me to clean my body."
    
    let errorResponse = "Please drag me to a clean station and tap the clean button!"
}

struct MantaRayCleaned: Character {
    let id = UUID()
    let displayName = "Manta Ray"
    
    let background = "You have been cleaned by the clean fish at the clean station. You feel much better now and want to help the little sea turtle find its mother."
    
    let firstLine = "Thank you for cleaning me! I feel much better now. I saw something that might be your mother heading towards the river in the bottom-left corner. You should swim along the river to find her!"
    
    let resumeConversationLine = "Swim along the river in the bottom-left corner to find your mother!"
    
    let hintForTurtle = "Swim along the river in the bottom-left corner of the screen to find your mother. The river will lead you to her!"
    
    let errorResponse = "Swim along the river in the bottom-left corner to find your mother!"
}
