# shiny-succostash
Server/Client Autorun scripts for Deadline (a Roblox game) that does a whole lot of monster stuff in a private server
- randomly selected weapons when you spawn
- many client and server-sided changes
- other stuff

To use:
1) Paste the code from the [deadline_monster_sv_auto_require.luau](https://raw.githubusercontent.com/mt7k/shiny-succostash/refs/heads/main/deadline_monster_sv_auto_require.luau) file into your private server's Server Autorun and update it. This is the require script for the server autorun code so it will automatically update when I update the main branch.
2) Paste the code from the [deadline_monster_client_autorun.luau](https://raw.githubusercontent.com/mt7k/shiny-succostash/refs/heads/main/deadline_monster_client_autorun.luau) file into your private server's Client Autorun section and update it. Since ``require()`` cannot be used on the client side, this code will not automatically update along with the Server Autorun when I update the main branch.

Last change to the client autorun: `May 20th, 2026`
