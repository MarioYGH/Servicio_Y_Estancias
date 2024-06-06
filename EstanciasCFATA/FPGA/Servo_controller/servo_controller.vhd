library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity servo_controller is
    Port (
        clk : in std_logic; -- Señal de 50MHz del FPGA
        reset : in std_logic; -- Reset
        switch : in std_logic_vector(6 downto 0); -- Switches para controlar la posición del servo
        servo : out std_logic -- Señal PWM de salida
    );
end servo_controller;

architecture combined_architecture of servo_controller is
    signal clk_128khz : std_logic;
    signal posicion : std_logic_vector(6 downto 0);
begin
    -- Instanciación del primer módulo para generar la señal de reloj a 128kHz
    clk_divider_inst : entity work.clk128kHz
        port map (
            clk => clk,
            reset => reset,
            clk_128khz => clk_128khz
        );

    -- Instanciación del segundo módulo para generar la señal PWM del servo
    servo_pwm_inst : entity work.servo_pwm
        port map (
            clk_128khz => clk_128khz,
            reset => reset,
            posicion => posicion,
            servo => servo
        );

    -- Proceso para actualizar la posición del servo según los switches
    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                posicion <= (others => '0');
            else
                posicion <= switch;
            end if;
        end if;
    end process;
end combined_architecture;
