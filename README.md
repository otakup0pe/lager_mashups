To use these handlers need to attach a  handler to lager_event. This can be done with the child specs in appropriate supervisors.

For lager_graphite_handler the arguments are the metrics in graphite to increment for warning/error messages.

{logger_graphite_handler, {lager_handler_watcher, start_link, [lager_event, lager_graphite_handler, [ErrorKey, WarningKey]]}, permanent, 3000, worker, [logger_graphite_handler]},

For lager_campfire_handler the arguments are the erlfire process to use, log level to pay attention to and destination campfire room.

{lager_campfire_handler, {lager_handler_watcher, start_link, [lager_event, lager_campfire_handler, [ErlfireName, Level, CampfireRoom]]}, permanent, 2000, worker, [nomura_event_sup]}