{ config, pkgs, ...}:

{
imports = [
    <home-manager/nixos>
];

home-manager.useGlobalPkgs = true;
home-manager.users.raoul = {
home.stateVersion = "23.05";
programs = {
    git = {
        enable = true;
        userName = "RaHoni";
        userEmail = "honisuess@gmail.com";
        signing = {
            key = "54D11CB37C713D5457ACF0C35962F3E9516FD551";
            signByDefault = true;
        };
    };
};

};

}
