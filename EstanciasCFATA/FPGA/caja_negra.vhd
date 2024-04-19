-- Declaración variables VHDL, ejemplos libro Sistemas digitales VHDL
-- std_logic logica estandar que indica que la terminal es de un solo bit 
-- Importante que el nombre del archivo sea el mismo que el de la declaración 

library IEEE;
use ieee.std_logic_1164.all

entity caja_negra is -- entity palabra reservada para inicializar la declaración, like a funcion
	port (
    A, B : in     std_logic; -- Entradas simples 
    X    : out    std_logic; -- Salida simple
    Y    : inout  std_logic; -- Bi-direccional
    W    : buffer std_logic -- Salida retroalimentada
	);
end caja_negra; -- cierre
	
