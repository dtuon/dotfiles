# Per-machine paths. THE ONLY FILE YOU EDIT ON A NEW MACHINE.
#
#   Copy-Item bootstrap\local.example.ps1 bootstrap\local.ps1
#
# Then change the paths below to match this machine and run `bootstrap\1-env.ps1`.
# This file is gitignored, so each machine keeps its own copy.
#
# Everything else is derived from these in lib.ps1 (Get-EnvMap), so the *shape*
# of the tree below Dropbox is stated once, in the repo, not once per machine.
# The dotfiles repo's own location is auto-detected and never configured here.

@{
    # The Dropbox folder that holds Documents\, Desktop\ and ether\.
    #
    # On a work machine with a Dropbox team space this is the deep one, e.g.
    #   <home>\<Org> Dropbox\<Full Name>\<Profile>
    # On a personal machine it's usually just
    #   <home>\Dropbox
    DropboxRoot = "$env:USERPROFILE\Dropbox"

    # Where code lives. Expected to contain the two repo folders below.
    Bedrock = "$env:USERPROFILE\bedrock"

    # Optional overrides, only if this machine clones them somewhere unusual.
    # Defaults are "$Bedrock\repos-dtuon" and "$Bedrock\repos-dale-primer-e".
    # ReposPersonal = 'D:\code\personal'
    # ReposWork     = 'D:\code\work'
}
