# PlainSight
A simple multiplayer game. Complete your objective without getting caught!
Topics - server/client connection with port-forwarding, multiplayer game design, object-oriented programming

The application starts on a lobby screen. On different networks, the host/server should share their public ip; on the same network, their private ip. After pressing "Host Game", a connection can be made with another player via port-forwarding. The client should type in the appropriate ip address and press "Join Game". From there, either player can begin the game.

!(/assets/images/lobbyscreen.PNG)

When the game begins, there are 12 red squares (2 players and 10 computers) with randomized positions and 4 larger black squares (pillars). Each player can identify themself with a "You" label visible only to them. Using the arrow keys, players can move their square in the cardinal directions. The goal is to touch each of the pillars once, resulting in a win.

Each player can attempt to reveal their opponent by clicking on them and immediately win the game, but a incorrect click results in an immediate loss. To avoid being found, one can disguise their movements with the randomized movement of the computers, effectively hiding in plain sight. 

Language: GDScript 3.5
Renderer: GLES 2
