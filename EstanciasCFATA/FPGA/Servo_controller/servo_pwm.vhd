library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity servo_pwm is
    Port (
        clk_128khz : in std_logic; -- Reloj a 128kHz
        reset : in std_logic; -- Reset
        posicion : in std_logic_vector(6 downto 0); -- Vector de 7 bits para la posición
        servo : out std_logic -- Señal PWM de salida
    );
end servo_pwm;

architecture behavioral of servo_pwm is
    signal cnt : unsigned(12 downto 0) := (others => '0'); -- Contador
    signal pwmi : unsigned(12 downto 0); -- Señal temporal para generar el pulso PWM
begin
    -- Contador de 128kHz
    process (reset, clk_128khz)
    begin
        if (reset = '1') then
            cnt <= (others => '0');
        elsif rising_edge(clk_128khz) then
            if (cnt = 2560) then
                cnt <= (others => '0');
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    -- Calcular el pulso PWM basado en la posición deseada
    process (posicion)
    begin
        -- Convertir la posición (0-120) a un pulso PWM adecuado
        -- El ancho de pulso varía desde 1ms (0 grados) hasta 2ms (120 grados)
        -- La frecuencia de la señal PWM es de 50Hz (periodo de 20ms)
        -- El número de ciclos de reloj de 128kHz en 1ms es 128 ciclos
		  -- El número de ciclos de reloj de 128kHz en 2ms es 256 ciclos
        -- Por lo tanto, el número de ciclos para un rango de 0 a 120 grados es de 128 a 256 ciclos
        pwmi <= to_unsigned(128, 13) + resize(unsigned(posicion)*2, 13);
    end process;

    -- Generar la señal PWM
    servo <= '1' when (cnt < pwmi) else '0';
end behavioral;
