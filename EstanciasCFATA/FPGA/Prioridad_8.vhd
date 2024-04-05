--Decodificador de prioridad con estructura if Para describir bajo VHDL al decodificador de prioridad, 
--la estructura case no es la mas adecuada debido a la gran cantidad de varibles de entrada
--La asignacion concurrente con los valores por omision debe declararse fuera de la estructura if 
--Si no se realiza la asignacion concurrente, el resultado de la sintesis será un circuito secuencial de memoria 
--En este decodificador de prioridad si el indicador Y es igual a 1 y cualquiera de los botones es 1 va a marcar su valor
--En caso de que se se presione mas de un valor debido a que es de prioridad, va a tomar el valor mas alto de los presionados
library IEEE;
use IEEE.std_logic_1164.all; --Libreria estandar

entity Prioridad_8 is 
	port(
		I: in std_logic_vector(0 to 7);     --Entradas
		Y: out std_logic;							--Seleccion
		B: out std_logic_vector(2 downto 0) --Salida codificada
		);
	end Prioridad_8;
	
-- Descripción del circuito 

architecture Decodificador of Prioridad_8 is 
	begin 
		process(I)
			begin
				if I(0)='1' then --inicio if
					Y <= '1';     --Activacion de I0
					B <= "000";   --Codigo de activacion
				elsif I(1)='1' then
					Y <= '1';
					B <= "001";
				elsif I(2)='1' then
					Y <= '1';
					B <= "010";
				elsif I(3)='1' then
					Y <= '1';
					B <= "011";
				elsif I(4)='1' then
					Y <= '1';
					B <= "100";
				elsif I(5)='1' then
					Y <= '1';
					B <= "101";
				elsif I(6)='1' then
					Y <= '1';
					B <= "110";
				elsif I(7)='1' then
					Y <= '1';
					B <= "111";
				else
					Y <= '0'; --valores por omision 
					B <= "111";
				end if;
			end process;
	end Decodificador;
