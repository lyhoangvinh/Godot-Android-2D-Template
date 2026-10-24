class_name MockBillingGateway
extends BillingGateway
## Unit-test fixture. Deliberately never marks production purchases owned.

var allow_test_purchases: bool = false
var _owned: Dictionary = {}


func purchase(product_id: String) -> void:
    var success: bool = OS.has_feature("editor") and allow_test_purchases and not product_id.is_empty()
    if success:
        _owned[product_id] = true
        entitlement_changed.emit(product_id, true)
    purchase_finished.emit(product_id, success)


func restore_purchases() -> void:
    for product_id: String in _owned.keys():
        entitlement_changed.emit(product_id, true)
