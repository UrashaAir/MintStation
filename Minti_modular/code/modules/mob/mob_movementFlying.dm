/mob/Process_FlyingS(movement_dir = 0)
    var/turf/T = get_turf(src)
    var/datum/gas_mixture/environment = T.return_air()
    if(HAS_TRAIT(src, TRAIT_FLUTTERS) && (environment.return_pressure() > 30))
        return TRUE
    . = ..()
