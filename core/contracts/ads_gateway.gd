class_name AdsGateway
extends Node
## Interface contract: production adapter must emit true ONLY for SDK earned reward callback.

signal rewarded_finished(placement: String, earned: bool)
signal interstitial_finished(placement: String)


func show_rewarded(_placement: String) -> void:
    push_error("AdsGateway requires a concrete adapter")


func show_interstitial(_placement: String) -> void:
    push_error("AdsGateway requires a concrete adapter")
