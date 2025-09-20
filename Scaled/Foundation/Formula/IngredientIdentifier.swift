import Foundation

public enum IngredientIdentifier: Hashable {
    case finalFlour(UUID)
    case finalWater
    case finalSalt
    case finalYeast
    case preferment(UUID)
    case prefermentFlour(UUID)
    case prefermentWater(UUID)
    case soaker(UUID)
    case inclusion(UUID)
    case enrichment(UUID)
}
