// Aurora Song - AS Medical Bounty System
// Separate implementation from NF Medical Bounty System
using Content.Shared._AS.Medical.Prototypes;

namespace Content.Shared._AS.Medical;

/// <summary>
/// Aurora Song: Component for entities with AS medical bounties
/// </summary>
[RegisterComponent]
[AutoGenerateComponentState]
public sealed partial class ASMedicalBountyComponent : Component
{
    /// <summary>
    /// The bounty to use/used for damage generation.
    /// If null, a medical bounty type will be selected at random.
    /// </summary>
    [DataField(serverOnly: true)]
    public ASMedicalBountyPrototype? Bounty = null;

    /// <summary>
    /// Maximum bounty value for this entity in spesos.
    /// Cached from bounty params on generation.
    /// </summary>
    [ViewVariables(VVAccess.ReadWrite), AutoNetworkedField]
    public int MaxBountyValue;

    /// <summary>
    /// Ensures damage is only applied once, set to true on startup.
    /// </summary>
    public bool BountyInitialized;
}
