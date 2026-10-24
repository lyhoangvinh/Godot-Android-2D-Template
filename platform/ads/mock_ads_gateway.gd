class_name MockAdsGateway
extends AdsGateway
## In-editor DEVELOPMENT ONLY; never wired to production reward granting.

var next_reward_succeeds: bool = true


func show_rewarded(placement: String) -> void:
    var earned: bool = OS.has_feature("editor") and next_reward_succeeds
    next_reward_succeeds = true
    rewarded_finished.emit(placement, earned)


func show_interstitial(placement: String) -> void:
    interstitial_finished.emit(placement)
