library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cont is 
port(clk: in std_logic;
	  sel: in std_logic_vector(4 downto 0);
	  conteo: buffer integer);
end entity;

architecture arqcont of cont is
begin 
	process (clk)
	begin 
		if (rising_edge(clk)) then
			case sel is 
			when "00001" => conteo <= 50;
			when "00010" => conteo <= 100;
			when "00001" => 
				if(conteo >= 100) then 
						conteo<=100;
				else 
						conteo <= conteo + 1;
				end if;
			when "01000" =>
				if(conteo <= 50) then 
						conteo<=50;
				else
						conteo <= conteo - 1;
				end if;
			when "10000" => conteo <= 75;
			when others => conteo <= conteo;
			end case;	
		end if;
		end process;
end architecture;
