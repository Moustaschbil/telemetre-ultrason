library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;

entity ip_telemetre is 
	port (
	clk : in std_logic;
	rst : in std_logic;
	echo : in std_logic;
	
	trig : out std_logic;
	HEX0 : out std_logic_vector(6 downto 0);
	HEX1 : out std_logic_vector(6 downto 0);
	HEX2 : out std_logic_vector(6 downto 0);
	HEX3 : out std_logic_vector(6 downto 0));

end ip_telemetre;

architecture behave of ip_telemetre is 

	signal cpt1 : integer; 		-- génère le trigger
	signal cpt2 : integer;		-- compte la durée de echo
	signal distance : integer;	-- distance calculée et affichée
	type Etat is (
		Etat0,			-- wait for echo
		Etat1,			-- cpt2 compte pendant l'écho
		Etat2			-- calcul la distance à partir de cpt, reset cp2
	);
	-- initialise Etat_present/futur à Etat_0
	signal Etat_present, Etat_futur : Etat := Etat0;

begin
	-- Trigger de 10 us toute les 60 ms
	trigger : process(rst,clk) begin
	if rst='1' then 
		cpt1 <= 0;
		trig <= '0';
	elsif (rising_edge(clk)) then
		if (cpt1 = 0) then    -- 0
			trig <= '1';
			cpt1 <= cpt1 + 1;		
		elsif (cpt1 = 499) then -- 10 us
			trig <= '0';  
			cpt1 <= cpt1 + 1;
		elsif (cpt1 = 3000499) then -- 60 ms
			trig <= '0';
			cpt1 <= 0;
		else 
			cpt1 <= cpt1 + 1;
		end if;
	end if;
	end process trigger;

	-- MAJ Etat_present
	Sequentiel_maj_etat : process (clk, reset) begin
	if reset = '0' then
		Etat_present <= Etat0;
	elsif clk'event and clk = '1' then
		Etat_present <= Etat_futur;
	end if;
	end process Sequentiel_maj_etat;

	-- Dynamique de changement d'état + Fonctionnement 
	Combinatoire_etats : process (clk, rst, echo, Etat_present) begin
	case Etat_present is
		when Etat0 => -- wait for echo
			if rising_edge(echo) then
				Etat_futur <= Etat1;
			else
				Etat_futur <= Etat0;
			end if;	
		when Etat1 => -- compte l'echo
			if falling_edge(echo) then
				Etat_futur <= Etat2;
			else
				Etat_futur <= Etat1;
				cpt2 <= cpt2 + 1;
			end if;
		when Etat2 => -- calcul distance
			Etat_futur <= Etat0;
			distance <= 340 * cpt2;
	end case;
	end process Combinatoire_etats;

end architecture;

/*
architecture behave of ip_telemetre is

	
end architecture behave;
*/