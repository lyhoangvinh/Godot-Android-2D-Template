class_name BillingGateway
extends Node
## No local entitlement flags establish a real purchase. Verify via Play Billing.

signal purchase_finished(product_id: String, success: bool)
signal entitlement_changed(product_id: String, owned: bool)


func purchase(_product_id: String) -> void:
    push_error("BillingGateway requires a concrete adapter")


func restore_purchases() -> void:
    push_error("BillingGateway requires a concrete adapter")
