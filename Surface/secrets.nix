{config, ...}:
{
sops.secrets = {
"ssh_host_ed25519_key" = {
    path = "/etc/ssh/ssh_host_ed25519_key";
    sopsFile = ../secrets/Surface/sshd.yaml;
};
"ssh_host_rsa_key" = {
    path = "/etc/ssh/ssh_host_rsa_key";
    sopsFile = ../secrets/Surface/sshd.yaml;
};
};
}
