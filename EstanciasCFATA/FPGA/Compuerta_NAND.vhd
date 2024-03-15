-- Compuerta NAND, <= es asignación directa y utilizamos la plabra reservada NAND para indicar que A y B realizaran esta operación 
-- Circuito simple

library IEEE;
use ieee.std_logic_1164.all -- Libreria estandar 

-- Se le llama black box, caja negra a la parte donde se declaran las varibles
-- Descripción en caja negra 
  
entity Compuerta_NAND is
	port (
	   A, B : in std_logic; -- Entradas simples
           F:     out std_logic; -- Salida simple
	);
end Compuerta_NAND;

-- Descripción del circuito 
  architecture simple of Compuerta_NAND is 
    begin 
      F <= A NAND B; -- Compuerta NAND 
    end simple;
