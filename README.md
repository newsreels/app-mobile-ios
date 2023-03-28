# newsreels-iOS

## important notes

- the pods had conflict, and the conflict resolved by customizing the pods locally (Pods in Pods directory) so the pod isn't part in the GitIgnored and it's not recommended to reinstall the pods.
the proper solution will be having these pods in a local module. untill we do that avoid reinstalling pods.

- the Service and Content App extensions are disable and removed from the build phases for now since they cause issue on running the app on actual devices. so far this not effection the extensions widgets.
