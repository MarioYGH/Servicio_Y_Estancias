--Multiplexor cuadruple, tiene 4 entradas y cada una es otro multiplexor, es un conjunto de multiplexores con la misma señal de control 
library IEEE;
use IEEE.std_logic_1164.all;

--Blackbox

entity Mux4_4_1 is 
port(
	I0, I1, I2, I3 : in  std_logic_vector(3 downto 0); --Entradas
	S :              in  std_logic_vector(1 downto 0); --Seleccion
	Y :              out std_logic_vector(3 downto 0) --Salida
	);
end Mux4_4_1;
--Descripción circuito 

architecture cuadruple of Mux4_4_1 is 
	begin 
		process(S,I0, I1, I2, I3) --Declaración del proceso 
			begin 
				case S is --Declaracion del case
					when "00" => Y <= I0; --Asignacion para S=00
					when "01" => Y <= I1; --Asignacion para S=01
					when "10" => Y <= I2; --Asignacion para S=10
					when others => Y <= I3; --Asignacion para S=11
				end case;
			end process;
		end cuadruple; 
