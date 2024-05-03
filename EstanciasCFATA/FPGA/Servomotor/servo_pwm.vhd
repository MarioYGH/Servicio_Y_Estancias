library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity servo_pwm is
	Port (
			clk_128khz : in std_logic; --reloj 128 que se diseño
			reset : in std_logic;  --reset
			posicion : in std_logic_vector(6 downto 0); --vector de 7 posiciones
			servo : out std_logic --Señal pwm de salida
	);
end servo_pwm;

architecture simple of servo_pwm is 

--Conter 

signal cnt : unsigned(12 downto 0);
--Temporal signal used to generate the PWM pulse 
signal pwmi : unsigned(8 downto 0);
signal pw : std_logic_vector(8 downto 0);
signal posicioon: unsigned (6 downto 0);

begin 
--Minium value should be 0.5ms

--Conter process
counter : process (reset, clk_128khz)
begin 
if (reset = '1') then 
	cnt <= (others => '0');

elsif rising_edge(clk_128khz) then 
	if(cnt = 2560 ) then 
		cnt <= (others => '0');
	else 
		cnt <= cnt + 1;
	end if;
end if;
end process;

--Output signal for the servomotor. 

posicioon <= unsigned(posicion);
comparador_90: process(posicioon)

begin 
if (posicioon < 90) then 
pwmi <= ((unsigned("00" & posicion))+68);
else
pw <= "010100000";
pwmi <= (unsigned(pw));
end if;
end process comparador_90;

servo <= '1' when (cnt < pwmi) else '0';

end simple;
