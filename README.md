IISDeploy
=========

Delopy asp.net website with github automatically

Here is the basic workflow:

1. login into your server.

2. install git.

3. fork this into your server.

4. config IIS, make sure the PostReceiveHook.ashx can be visit from
internet.

5. create a repository on github to hold the published/compiled web
project files, such as dlls, views.

2. setup webhook url in the github repo, point to
(postreceivehook.ashx).

3. clone this in your local computer and server

3. Publish from vs to the local repo.

4. commit & push to github

...

your site get updated :)
