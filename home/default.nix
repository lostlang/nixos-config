{ stateVersion, user,  ... }: {
imports = [
	./modules
];

home = {
	username = user;
	homeDirectory = "/home/${user}";
	stateVersion = stateVersion;
};
}
