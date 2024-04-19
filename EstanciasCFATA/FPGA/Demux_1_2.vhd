library IEEE;
use IEEE.std_logic_1164.all;

--Blackbox

entity Demux_1_2 is 
port(
	X : in std_logic; --Entradas
	S : in std_logic; --Seleccion
	Y : out std_logic_vector(1 downto 0) --Salida
	);
  end Demux_1_2;
--Descripción circuito 

architecture simple of Demux_1_2 is 
	begin 
	  Y(0) <= X when (S='0') else '0'; --Asignacion condicional	
          Y(1) <= X when (S='1') else '0'; --Asignacion condicional	
	end simple; 
