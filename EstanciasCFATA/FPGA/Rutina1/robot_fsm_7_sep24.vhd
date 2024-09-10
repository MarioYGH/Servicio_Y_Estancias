library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity robot_fsm is
    Port (
        clk : in std_logic; -- Señal de 50MHz del FPGA
        reset : in std_logic; -- Reset
        button : in std_logic; -- Botón para iniciar la secuencia
        servo1, servo2, servo3, servo4 : out std_logic -- Señales PWM de salida para los servos
    );
end robot_fsm;

architecture fsm_arch of robot_fsm is
    signal clk_128khz : std_logic;
    signal posicion1, posicion2, posicion3, posicion4 : std_logic_vector(6 downto 0);
    type state_type is (idle, step1, step2, step3, rest);
    signal state, next_state : state_type;
    signal counter : integer := 0;

    -- Constantes de delay específicas para cada paso
    constant DELAY1 : integer := 50000000; -- 1 segundo
    constant DELAY2 : integer := 25000000; -- 0.5 segundos
    signal delay_value : integer := 50000000; -- Valor de delay por defecto

    -- Posiciones iniciales (todos los motores en 0°)
    constant INIT_POS1 : std_logic_vector(6 downto 0) := "0101001"; -- M1 cadera derecha (0°)
    constant INIT_POS2 : std_logic_vector(6 downto 0) := "0011000"; -- M2 cadera izquierda (0°)
    constant INIT_POS3 : std_logic_vector(6 downto 0) := "1000001"; -- M3 rodilla derecha (0°)
    constant INIT_POS4 : std_logic_vector(6 downto 0) := "0111110"; -- M4 rodilla izquierda (0°)

    -- Posiciones de movimiento para la caminata, ajustando el sentido de los motores
    constant MOVE_POS1 : std_logic_vector(6 downto 0) := "0110100"; -- M1 cadera derecha (antihorario, +30°)
    constant MOVE_POS2 : std_logic_vector(6 downto 0) := "0001110"; -- M2 cadera izquierda (horario, +30°)
    constant MOVE_POS3 : std_logic_vector(6 downto 0) := "0111111"; -- M3 rodilla derecha (antihorario, +20°)
    constant MOVE_POS4 : std_logic_vector(6 downto 0) := "0100001"; -- M4 rodilla izquierda (horario, -20°)

begin
    -- Instanciación del módulo del divisor de frecuencia
    clk_divider_inst : entity work.clk128kHz
        port map (
            clk => clk,
            reset => reset,
            clk_128khz => clk_128khz
        );

    -- Instanciación de los módulos del controlador PWM del servo
    servo1_pwm_inst : entity work.servo_pwm
        port map (
            clk_128khz => clk_128khz,
            reset => reset,
            posicion => posicion1,
            servo => servo1
        );

    servo2_pwm_inst : entity work.servo_pwm
        port map (
            clk_128khz => clk_128khz,
            reset => reset,
            posicion => posicion2,
            servo => servo2
        );

    servo3_pwm_inst : entity work.servo_pwm
        port map (
            clk_128khz => clk_128khz,
            reset => reset,
            posicion => posicion3,
            servo => servo3
        );

    servo4_pwm_inst : entity work.servo_pwm
        port map (
            clk_128khz => clk_128khz,
            reset => reset,
            posicion => posicion4,
            servo => servo4
        );

    -- Máquina de estados
    process (clk, reset)
    begin
        if reset = '1' then
            state <= idle;
            counter <= 0;
        elsif rising_edge(clk) then
            if counter = delay_value then
                state <= next_state;
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    process (state, button)
    begin
        case state is
            when idle =>
                if button = '1' then
                    next_state <= step1;
                    delay_value <= DELAY1;
                else
                    next_state <= idle;
                    delay_value <= DELAY1;
                end if;

            when step1 =>
                -- Posición inicial (todos los motores en 0°)
                posicion1 <= INIT_POS1;
                posicion2 <= INIT_POS2;
                posicion3 <= INIT_POS3;
                posicion4 <= INIT_POS4;
                next_state <= step2;
                delay_value <= DELAY1;

            when step2 =>
                -- Mover M1 (cadera derecha adelante, antihorario) y M3 (rodilla derecha flexiona, antihorario)
                posicion1 <= MOVE_POS1;
                posicion3 <= MOVE_POS3;
                next_state <= step3;
                delay_value <= DELAY1;

            when step3 =>
                -- Mover M2 (cadera izquierda adelante, horario) y M4 (rodilla izquierda flexiona, horario)
                posicion2 <= MOVE_POS2;
                posicion4 <= MOVE_POS4;
                next_state <= rest;
                delay_value <= DELAY1;

            when rest =>
                -- Volver a la posición inicial
                posicion1 <= INIT_POS1;
                posicion2 <= INIT_POS2;
                posicion3 <= INIT_POS3;
                posicion4 <= INIT_POS4;
                next_state <= idle;
                delay_value <= DELAY1;

            when others =>
                next_state <= idle;
                delay_value <= DELAY1;
        end case;
    end process;

end fsm_arch;
