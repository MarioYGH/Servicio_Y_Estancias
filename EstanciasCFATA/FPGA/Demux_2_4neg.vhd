library IEEE;
use IEEE.std_logic_1164.all;

--Blackbox

entity Demux_2_4neg is 
port(
	X : in  std_logic; --Entradas
	S : in  std_logic_vector(1 downto 0); --Seleccion
	Y : out std_logic_vector(3 downto 0) --Salida
	);
end Demux_2_4neg;
--Descripción circuito 

architecture cuadruple of Demux_2_4neg is 
	begin 
		process(X,S) --Declaración del proceso 
			begin 
        Y <= "1111" --Valores por omision
				case S is --Declaracion del case
					when "00" => Y <= NOT X; --Logica Negativa
					when "01" => Y <= NOT X; --Logica Negativa
					when "10" => Y <= NOT X; --Logica Negativa
					when others => Y <= NOT X; --Logica Negativa
				end case;
			end process;
		end cuadruple; 
