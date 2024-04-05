library IEEE;
use IEEE.std_logic_1164.all;

--Blackbox

entity Mux_8_1 is 
port(
	I : in std_logic_vector(7 downto 0); --Entradas
	S : in std_logic_vector(2 downto 0); --Seleccion
	Y : out std_logic --Salida
	);
--Descripción circuito 

architecture simple of Mux_8_1 is 
	begin 
		process(S,I) --Declaración del proceso 
			begin 
				case S is --Declaracion del case
					when "000" => Y <= I(0); --Asignacion para S=000
					when "001" => Y <= I(1); --Asignacion para S=001
					when "010" => Y <= I(2); --Asignacion para S=010
					when "011" => Y <= I(3); --Asignacion para S=011
					when "100" => Y <= I(4); --Asignacion para S=100
					when "101" => Y <= I(5); --Asignacion para S=101
					when "110" => Y <= I(6); --Asignacion para S=110
					when others => Y <= I(7); --Asignacion para S=111
				end case;
			end process;
		end simple; 
