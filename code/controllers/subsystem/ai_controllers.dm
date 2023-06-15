/// The subsystem used to tick [/datum/ai_controllers] instances. Handling the re-checking of plans.
SUBSYSTEM_DEF(ai_controllers)
	name = "AI Controller Ticker"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_AI_CONTROLLERS
	wait = 0.5 SECONDS //Plan every half second if required, not great not terrible.

	///List of all ai_subtree singletons, key is the typepath while assigned value is a newly created instance of the typepath. See setup_subtrees()
	var/list/ai_subtrees = list()
	///List of all ai controllers currently running
	var/list/active_ai_controllers = list()

/datum/controller/subsystem/ai_controllers/Initialize()
	setup_subtrees()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ai_controllers/proc/setup_subtrees()
	ai_subtrees = list()
	for(var/subtree_type in subtypesof(/datum/ai_planning_subtree))
		var/datum/ai_planning_subtree/subtree = new subtree_type
		ai_subtrees[subtree_type] = subtree

/datum/controller/subsystem/ai_controllers/fire(resumed)
	for(var/datum/ai_controller/ai_controller as anything in active_ai_controllers)
		if(!COOLDOWN_FINISHED(ai_controller, failed_planning_cooldown))
			continue

		var/client/C
		var/_run = FALSE
		if(ismob(ai_controller.pawn))
			var/mob/_pawn = ai_controller.pawn
			for(C in GLOB.clients)
				var/has_mob = !isnull(C.mob)
				if(has_mob)
					if(get_dist(C.mob, _pawn) < 15)
						_run = TRUE
						break

		if(!_run)
			continue
			
		if(!ai_controller.able_to_plan())
			continue
		ai_controller.SelectBehaviors(wait * 0.1)
		if(!LAZYLEN(ai_controller.current_behaviors)) //Still no plan
			COOLDOWN_START(ai_controller, failed_planning_cooldown, AI_FAILED_PLANNING_COOLDOWN)
