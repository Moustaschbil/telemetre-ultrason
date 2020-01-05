library ieee;
use ieee.std_logic_1164.all;


entity tb_ip_telemetre is
end tb_ip_telemetre;

architecture tb of tb_ip_telemetre is

	signal clk, rst, echo : std_logic;
	signal trig : std_logic;
	signal h0, h1, h2, h3 : std_logic_vector(6 downto 0);		-- 7seg
begin

	IP_TEL : entity work.ip_telemetre port map (
		clk => clk,
		rst => rst,
		echo => echo,
		trig => trig,
		HEX0 => h0,
		HEX1 => h1,
		HEX2 => h2,
		HEX3 => h3);

	rst <= '1', '0' after 20 ns;
	
	clock : process 
	begin
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
	end process;
end tb ;