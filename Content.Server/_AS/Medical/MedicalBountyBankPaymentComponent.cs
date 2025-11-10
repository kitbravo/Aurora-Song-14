// Aurora Song - AS Medical Bounty System
// Separate implementation from NF Medical Bounty System
using Content.Shared._NF.Bank.Components;

namespace Content.Server._AS.Medical;

/// <summary>
/// Aurora Song: Component for entities that can receive AS medical bounty payments
/// </summary>
[RegisterComponent]
public sealed partial class ASMedicalBountyBankPaymentComponent : Component
{
    [DataField(required: true)]
    public SectorBankAccount Account;
}
